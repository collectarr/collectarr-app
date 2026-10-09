import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final class LibraryCollectionSummary {
  const LibraryCollectionSummary(
      {required this.id,
      required this.kind,
      required this.name,
      required this.position,
      this.entryIds = const {},
      this.isActive = false});
  final String id;
  final String kind;
  final String name;
  final int position;
  final bool isActive;
  final Set<String> entryIds;
  int get count => entryIds.length;
}

final class LibraryCollectionRepository {
  const LibraryCollectionRepository(this.db);
  final LocalDatabase db;

  Future<List<LibraryCollectionSummary>> list(String kind) async {
    _requireKind(kind);
    final rows = await (db.select(db.libraryCollections)
          ..where((t) => t.kind.equals(kind))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    return [
      for (final row in rows)
        LibraryCollectionSummary(
            id: row.id,
            kind: row.kind,
            name: row.name,
            position: row.position,
            isActive: row.isActive)
    ];
  }

  Future<String> ensureDefault(String kind) => db.transaction(() async {
        var collections = await list(kind);
        if (collections.isEmpty) {
          await db.into(db.libraryCollections).insert(
              LibraryCollectionsCompanion.insert(
                  id: 'main-$kind',
                  kind: kind,
                  name: 'Main Collection',
                  position: 0,
                  isActive: const Value(true)),
              mode: InsertMode.insertOrIgnore);
          collections = await list(kind);
        }
        final destination = collections.first.id;
        await db.customInsert(
            'INSERT OR IGNORE INTO library_collection_memberships (entry_kind, entry_id, collection_id) SELECT kind, id, ? FROM library_entries WHERE kind = ?',
            variables: [Variable(destination), Variable(kind)],
            updates: {db.libraryCollectionMemberships});
        return destination;
      });

  Future<void> assignNewEntry(LibraryEntryRef ref) async {
    var collections = await list(ref.kind.apiValue);
    if (collections.isEmpty) {
      await ensureDefault(ref.kind.apiValue);
      collections = await list(ref.kind.apiValue);
    }
    final destination =
        collections.where((c) => c.isActive).firstOrNull ?? collections.first;
    await db.into(db.libraryCollectionMemberships).insert(
        LibraryCollectionMembershipsCompanion.insert(
            entryKind: ref.kind.apiValue,
            entryId: ref.id.value,
            collectionId: destination.id),
        mode: InsertMode.insertOrIgnore);
  }

  Future<void> activate(String id) => db.transaction(() async {
        final collection = await _find(id);
        await (db.update(db.libraryCollections)
              ..where((t) => t.kind.equals(collection.kind)))
            .write(const LibraryCollectionsCompanion(isActive: Value(false)));
        await (db.update(db.libraryCollections)..where((t) => t.id.equals(id)))
            .write(const LibraryCollectionsCompanion(isActive: Value(true)));
      });

  Stream<List<LibraryCollectionSummary>> watch(String kind) async* {
    await ensureDefault(kind);
    yield* db
        .customSelect('''SELECT c.id, c.kind, c.name, c.position, c.is_active, e.id AS entry_id
      FROM library_collections c
      LEFT JOIN library_collection_memberships m ON m.collection_id = c.id AND m.entry_kind = c.kind
      LEFT JOIN library_entries e ON e.kind = m.entry_kind AND e.id = m.entry_id AND e.deleted_at IS NULL
      WHERE c.kind = ? ORDER BY c.position''', variables: [
          Variable(kind)
        ], readsFrom: {
          db.libraryCollections,
          db.libraryCollectionMemberships,
          db.libraryEntries
        })
        .watch()
        .map((rows) {
          final entries = <String, Set<String>>{};
          final collections = <String, LibraryCollectionSummary>{};
          for (final row in rows) {
            final id = row.read<String>('id');
            final members = entries.putIfAbsent(id, () => {});
            final entryId = row.readNullable<String>('entry_id');
            if (entryId != null) members.add(entryId);
            collections.putIfAbsent(
                id,
                () => LibraryCollectionSummary(
                    id: id,
                    kind: row.read<String>('kind'),
                    name: row.read<String>('name'),
                    position: row.read<int>('position'),
                    isActive: row.read<bool>('is_active')));
          }
          return [
            for (final collection in collections.values)
              LibraryCollectionSummary(
                  id: collection.id,
                  kind: collection.kind,
                  name: collection.name,
                  position: collection.position,
                  isActive: collection.isActive,
                  entryIds: Set.unmodifiable(entries[collection.id]!))
          ];
        });
  }

  Future<LibraryCollectionSummary> create(String kind, String name) =>
      db.transaction(() async {
        _requireKind(kind);
        final normalized = _name(name);
        final current = await list(kind);
        if (current
            .any((c) => c.name.toLowerCase() == normalized.toLowerCase())) {
          throw ArgumentError('A collection with this name already exists.');
        }
        final id = const Uuid().v4();
        final position = current.length;
        await db.into(db.libraryCollections).insert(
            LibraryCollectionsCompanion.insert(
                id: id, kind: kind, name: normalized, position: position));
        return LibraryCollectionSummary(
            id: id, kind: kind, name: normalized, position: position);
      });

  Future<void> rename(String id, String name) => db.transaction(() async {
        final collection = await _find(id);
        final normalized = _name(name);
        if ((await list(collection.kind)).any((c) =>
            c.id != id && c.name.toLowerCase() == normalized.toLowerCase())) {
          throw ArgumentError('A collection with this name already exists.');
        }
        await (db.update(db.libraryCollections)..where((t) => t.id.equals(id)))
            .write(LibraryCollectionsCompanion(name: Value(normalized)));
      });

  Future<void> move(Iterable<LibraryEntryRef> refs, String destinationId) =>
      db.transaction(() async {
        final destination = await _find(destinationId);
        final entries = refs.toSet();
        for (final ref in entries) {
          if (ref.kind.apiValue != destination.kind) {
            throw ArgumentError(
                'Entries and collection must have the same kind.');
          }
          final row = await (db.select(db.libraryEntries)
                ..where((t) =>
                    t.kind.equals(destination.kind) &
                    t.id.equals(ref.id.value) &
                    t.deletedAt.isNull()))
              .getSingleOrNull();
          if (row == null) {
            throw ArgumentError('The selected library entry no longer exists.');
          }
        }
        for (final ref in entries) {
          await db.into(db.libraryCollectionMemberships).insertOnConflictUpdate(
              LibraryCollectionMembershipsCompanion.insert(
                  entryKind: destination.kind,
                  entryId: ref.id.value,
                  collectionId: destinationId));
        }
      });

  Future<void> delete(String id, {required String moveTo}) =>
      db.transaction(() async {
        final source = await _find(id);
        final destination = await _find(moveTo);
        if (id == moveTo || source.kind != destination.kind) {
          throw ArgumentError('Choose another collection of the same kind.');
        }
        await (db.update(db.libraryCollectionMemberships)
              ..where((t) => t.collectionId.equals(id)))
            .write(LibraryCollectionMembershipsCompanion(
                collectionId: Value(moveTo)));
        if (source.isActive) await activate(moveTo);
        await (db.delete(db.libraryCollections)..where((t) => t.id.equals(id)))
            .go();
        await reorder(
            source.kind, (await list(source.kind)).map((c) => c.id).toList());
      });

  Future<void> reorder(String kind, List<String> ids) =>
      db.transaction(() async {
        final existing = await list(kind);
        if (ids.toSet().length != ids.length ||
            ids.length != existing.length ||
            !ids.toSet().containsAll(existing.map((c) => c.id))) {
          throw ArgumentError(
              'Collection order must contain every collection exactly once.');
        }
        for (var i = 0; i < ids.length; i++) {
          await (db.update(db.libraryCollections)
                ..where((t) => t.id.equals(ids[i])))
              .write(LibraryCollectionsCompanion(position: Value(i)));
        }
      });

  Future<LibraryCollectionSummary> _find(String id) async {
    final row = await (db.select(db.libraryCollections)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) throw ArgumentError('Collection no longer exists.');
    return LibraryCollectionSummary(
        id: row.id,
        kind: row.kind,
        name: row.name,
        position: row.position,
        isActive: row.isActive);
  }

  static String _name(String name) {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError('Enter a collection name.');
    return value;
  }

  static void _requireKind(String kind) {
    if (catalogMediaKindFromApiValue(kind).isUnknown) {
      throw ArgumentError.value(kind, 'kind');
    }
  }
}

final libraryCollectionsProvider = StreamProvider.autoDispose
    .family<List<LibraryCollectionSummary>, String>((ref, kind) =>
        LibraryCollectionRepository(ref.watch(localDatabaseProvider))
            .watch(kind));
String? activeLibraryCollectionId(List<LibraryCollectionSummary> collections) =>
    (collections.where((c) => c.isActive).firstOrNull ??
            collections.firstOrNull)
        ?.id;
