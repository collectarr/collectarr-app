import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:drift/drift.dart';
import 'models/pick_list_value.dart';

/// References stored outside catalog metadata, addressed by their own identity.
final class PickListReferences {
  const PickListReferences(this.db);
  final LocalDatabase db;
  static const personalKeys = {
    'owners': 'owner_label',
    'tags': 'tags',
    'purchase_store': 'purchase_store',
    'sold_to': 'sold_to',
    'collection_status': 'collection_status',
  };
  bool handles(String listName) =>
      personalKeys.containsKey(listName) ||
      listName == 'locations' ||
      listName == 'borrower' ||
      listName.endsWith('.image_type');

  Future<Map<String, Set<LibraryEntryRef>>> usages(
      String listName, String? mediaKind) async {
    final entries = await LibraryEntryStore(db).list();
    final active = {
      for (final entry in entries)
        if (mediaKind == null || entry.kind.apiValue == mediaKind)
          LibraryEntryRef(kind: entry.kind, id: LibraryEntryId(entry.id)): entry
    };
    final result = <String, Set<LibraryEntryRef>>{};
    void add(String? value, LibraryEntryRef ref) {
      if (value == null || value.trim().isEmpty || !active.containsKey(ref)) {
        return;
      }
      result.putIfAbsent(value.trim(), () => <LibraryEntryRef>{}).add(ref);
    }

    final key = personalKeys[listName];
    if (key != null) {
      for (final entry in active.entries) {
        final raw = entry.value.personalData[key] as String?;
        for (final value
            in listName == 'tags' ? raw?.split(',') ?? <String>[] : [raw]) {
          add(value, entry.key);
        }
      }
    } else if (listName == 'locations') {
      final locations = {
        for (final location in await LocationRepository(db).getAll())
          location.id: location.name
      };
      for (final entry in active.entries) {
        add(locations[entry.value.personalData['location_id']], entry.key);
      }
      // Include locations without assignments in the dictionary.
      for (final value in locations.values) {
        result.putIfAbsent(value, () => <LibraryEntryRef>{});
      }
    } else if (listName == 'borrower') {
      for (final row in await db.select(db.loansCache).get()) {
        add(row.borrowerName, LibraryEntryRef.fromKey(row.libraryEntryRefKey));
      }
    } else if (listName.endsWith('.image_type')) {
      for (final row in await db.select(db.itemImagesCache).get()) {
        if (row.imageType == 'front_cover' || row.imageType == 'back_cover') {
          continue;
        }
        add(
            row.imageType.startsWith('personal:')
                ? row.imageType.substring(9)
                : row.imageType,
            LibraryEntryRef.fromKey(row.libraryEntryRefKey));
      }
    }
    return result;
  }

  Future<void> replace(String listName, String? mediaKind, Set<String> sources,
      String target) async {
    final affected = <LibraryEntryRef>{};
    final entries = await LibraryEntryStore(db).list();
    final active = {
      for (final entry in entries)
        if (mediaKind == null || entry.kind.apiValue == mediaKind)
          LibraryEntryRef(kind: entry.kind, id: LibraryEntryId(entry.id)): entry
    };
    bool matches(String? value) =>
        value != null && sources.contains(normalizePickListValue(value));
    final key = personalKeys[listName];
    if (key != null) {
      for (final entry in active.entries) {
        final raw = entry.value.personalData[key] as String?;
        final values =
            listName == 'tags' ? raw?.split(',') ?? <String>[] : [raw];
        if (!values.any(matches)) continue;
        final seen = <String>{};
        final replaced = [
          for (final value in values)
            if (value != null) matches(value) ? target : value
        ]
            .where((value) =>
                value.trim().isNotEmpty &&
                seen.add(normalizePickListValue(value)))
            .join(', ');
        await LibraryEntryStore(db).updatePersonal(entry.value.kind,
            entry.value.id, {key: replaced.isEmpty ? null : replaced});
        affected.add(entry.key);
      }
    } else if (listName == 'locations') {
      final repository = LocationRepository(db);
      final locations = await repository.getAll();
      StorageLocation? destination;
      for (final location in locations) {
        if (normalizePickListValue(location.name) ==
            normalizePickListValue(target)) {
          destination = location;
        }
      }
      for (final source
          in locations.where((location) => matches(location.name))) {
        if (source.id == destination?.id) {
          if (source.name != target) {
            await repository.update(StorageLocation(
                id: source.id,
                name: target,
                parentId: source.parentId,
                description: source.description,
                sortOrder: source.sortOrder));
          }
          continue;
        }
        if (destination == null && target.isNotEmpty) {
          // Rename preserves location identity and its children.
          await repository.update(StorageLocation(
              id: source.id,
              name: target,
              parentId: source.parentId,
              description: source.description,
              sortOrder: source.sortOrder));
          destination = StorageLocation(
              id: source.id,
              name: target,
              parentId: source.parentId,
              description: source.description,
              sortOrder: source.sortOrder);
          continue;
        }
        for (final entry in active.entries) {
          if (entry.value.personalData['location_id'] != source.id) continue;
          await LibraryEntryStore(db).updatePersonal(entry.value.kind,
              entry.value.id, {'location_id': destination?.id});
          affected.add(entry.key);
        }
        if (destination != null) {
          final current = {
            for (final location in await repository.getAll())
              location.id: location
          };
          var ancestor = destination.parentId;
          final seen = <String>{};
          while (ancestor != null && seen.add(ancestor)) {
            if (ancestor == source.id) {
              await repository.update(StorageLocation(
                  id: destination.id,
                  name: destination.name,
                  parentId: source.parentId,
                  description: destination.description,
                  sortOrder: destination.sortOrder));
              break;
            }
            ancestor = current[ancestor]?.parentId;
          }
        }
        for (final child in (await repository.getAll())
            .where((child) => child.parentId == source.id)) {
          if (child.id == destination?.id) continue;
          await repository.update(StorageLocation(
              id: child.id,
              name: child.name,
              parentId: destination?.id ?? source.parentId,
              description: child.description,
              sortOrder: child.sortOrder));
        }
        await repository.delete(source.id);
      }
    } else if (listName == 'borrower') {
      for (final row in await db.select(db.loansCache).get()) {
        final ref = LibraryEntryRef.fromKey(row.libraryEntryRefKey);
        if (!active.containsKey(ref) || !matches(row.borrowerName)) continue;
        // Removing a name retains loan dates and notes.
        await (db.update(db.loansCache)..where((t) => t.id.equals(row.id)))
            .write(LoansCacheCompanion(borrowerName: Value(target)));
        affected.add(ref);
      }
    } else if (listName.endsWith('.image_type')) {
      for (final row in await db.select(db.itemImagesCache).get()) {
        final ref = LibraryEntryRef.fromKey(row.libraryEntryRefKey);
        if (!active.containsKey(ref) ||
            !row.imageType.startsWith('personal:') &&
                (row.imageType == 'front_cover' ||
                    row.imageType == 'back_cover')) {
          continue;
        }
        final value = row.imageType.startsWith('personal:')
            ? row.imageType.substring(9)
            : row.imageType;
        if (!matches(value)) continue;
        final replacement = target;
        await (db.update(db.itemImagesCache)..where((t) => t.id.equals(row.id)))
            .write(ItemImagesCacheCompanion(
                imageType: Value(row.imageType.startsWith('personal:')
                    ? 'personal:$replacement'
                    : replacement)));
        affected.add(ref);
      }
    }
    for (final ref in affected) {
      await enqueueLibraryEntrySnapshot(db, ref);
    }
  }
}
