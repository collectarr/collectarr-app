import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:drift/drift.dart';

class UserExternalLinksCacheRepository {
  const UserExternalLinksCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<UserExternalLink>> listByCatalogRef(
    CatalogEntityRef catalogRef,
  ) async {
    final rows = await (_db.select(_db.userExternalLinksCache)
          ..orderBy([
            (row) => OrderingTerm.asc(row.kind),
            (row) => OrderingTerm.asc(row.label),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
    return rows
        .map(_fromRow)
        .where((link) => _sameCatalogRef(link.catalogRef, catalogRef))
        .toList(growable: false);
  }

  Future<void> replaceForCatalogRef(
    CatalogEntityRef catalogRef,
    Iterable<UserExternalLink> links,
  ) async {
    final normalized = links.where((link) => link.url.trim().isNotEmpty);
    await _db.transaction(() async {
      final rows = await _db.select(_db.userExternalLinksCache).get();
      for (final row in rows) {
        final existing = _fromRow(row);
        if (_sameCatalogRef(existing.catalogRef, catalogRef)) {
          await (_db.delete(_db.userExternalLinksCache)
                ..where((entry) => entry.id.equals(row.id)))
              .go();
        }
      }
      for (final link in normalized) {
        await _db.into(_db.userExternalLinksCache).insert(
              UserExternalLinksCacheCompanion.insert(
                id: link.id,
                catalogRefJson: jsonEncode(link.catalogRef.toJson()),
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
    final rawRef = jsonDecode(row.catalogRefJson);
    if (rawRef is! Map) {
      throw FormatException(
        'External link ${row.id} contains an invalid catalog reference',
      );
    }
    return UserExternalLink(
      id: row.id,
      catalogRef: CatalogEntityRef.fromJson(
        Map<String, dynamic>.from(rawRef),
      ),
      label: row.label,
      url: row.url,
      kind: row.kind,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  bool _sameCatalogRef(CatalogEntityRef left, CatalogEntityRef right) {
    return left.kind == right.kind &&
        left.entityType == right.entityType &&
        left.id == right.id;
  }
}
