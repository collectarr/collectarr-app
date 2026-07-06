import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:drift/drift.dart';

class UserExternalLinksCacheRepository {
  const UserExternalLinksCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<UserExternalLink>> listByItemId(String itemId) async {
    final rows = await (_db.select(_db.userExternalLinksCache)
          ..where((row) => row.itemId.equals(itemId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.kind),
            (row) => OrderingTerm.asc(row.label),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> replaceForItem(
    String itemId,
    Iterable<UserExternalLink> links,
  ) async {
    final normalized = links.where((link) => link.url.trim().isNotEmpty);
    await _db.transaction(() async {
      await (_db.delete(_db.userExternalLinksCache)
            ..where((row) => row.itemId.equals(itemId)))
          .go();
      for (final link in normalized) {
        await _db.into(_db.userExternalLinksCache).insert(
              UserExternalLinksCacheCompanion.insert(
                id: link.id,
                itemId: link.itemId,
                editionId: Value(link.editionId),
                variantId: Value(link.variantId),
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
      itemId: row.itemId,
      editionId: row.editionId,
      variantId: row.variantId,
      label: row.label,
      url: row.url,
      kind: row.kind,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
