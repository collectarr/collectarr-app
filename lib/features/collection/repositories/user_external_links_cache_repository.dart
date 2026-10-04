import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:drift/drift.dart';

class UserExternalLinksCacheRepository {
  const UserExternalLinksCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<UserExternalLink>> listByLibraryEntryRef(
    LibraryEntryRef libraryEntryRef,
  ) async {
    requireKnownLibraryEntryRef(libraryEntryRef, 'externalLink.libraryEntryRef');
    final rows = await (_db.select(_db.userExternalLinksCache)
          ..where((row) => row.libraryEntryRefKey.equals(libraryEntryRef.key))
          ..orderBy([
            (row) => OrderingTerm.asc(row.kind),
            (row) => OrderingTerm.asc(row.label),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<Map<LibraryEntryRef, List<UserExternalLink>>> listGroupedByEntry(
    Iterable<LibraryEntryRef> refs,
  ) async {
    final values = refs.toSet();
    for (final ref in values) {
      requireKnownLibraryEntryRef(ref, 'externalLink.libraryEntryRef');
    }
    final wanted = values;
    if (wanted.isEmpty) return const {};
    final grouped = <LibraryEntryRef, List<UserExternalLink>>{};
    final rows = await _db.select(_db.userExternalLinksCache).get();
    for (final row in rows) {
      final link = _fromRow(row);
      if (!wanted.contains(link.libraryEntryRef)) continue;
      grouped.putIfAbsent(link.libraryEntryRef, () => []).add(link);
    }
    return {
      for (final entry in grouped.entries)
        entry.key: List.unmodifiable(entry.value),
    };
  }

  Future<void> replaceForLibraryEntry(
    LibraryEntryRef libraryEntryRef,
    Iterable<UserExternalLink> links,
  ) async {
    requireKnownLibraryEntryRef(libraryEntryRef, 'externalLink.libraryEntryRef');
    final normalized = links
        .where((link) => link.url.trim().isNotEmpty)
        .toList(growable: false);
    for (final link in normalized) {
      requireKnownLibraryEntryRef(link.libraryEntryRef, 'externalLink.libraryEntryRef');
      if (link.libraryEntryRef != libraryEntryRef) {
        throw ArgumentError(
          'External link ${link.id} targets a different library entry.',
        );
      }
    }
    await _db.transaction(() async {
      await (_db.delete(_db.userExternalLinksCache)
            ..where((row) => row.libraryEntryRefKey.equals(libraryEntryRef.key)))
          .go();
      for (final link in normalized) {
        await _db.into(_db.userExternalLinksCache).insert(
              UserExternalLinksCacheCompanion.insert(
                id: link.id,
                libraryEntryRefKey: Value(link.libraryEntryRef.key),
                label: link.label,
                url: link.url,
                kind: link.kind,
                createdAt: link.createdAt,
                updatedAt: link.updatedAt,
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
  }

  UserExternalLink _fromRow(UserExternalLinksCacheData row) {
    return UserExternalLink(
      id: row.id,
      libraryEntryRef: LibraryEntryRef.fromKey(row.libraryEntryRefKey),
      label: row.label,
      url: row.url,
      kind: row.kind,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> replaceSyncedForLibraryEntry(
    LibraryEntryRef ref,
    List<UserExternalLink> links,
  ) async {
    await replaceForLibraryEntry(ref, links);
  }
}
