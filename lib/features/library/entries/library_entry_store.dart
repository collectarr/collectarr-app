import 'dart:convert';

import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:drift/drift.dart';

/// The sole persistence boundary for complete local library entries.
final class LibraryEntryStore {
  const LibraryEntryStore(this.database);
  final LocalDatabase database;

  Future<LibraryEntryRecord?> find(CatalogMediaKind kind, String id) async {
    final row = await (database.select(database.libraryEntries)
          ..where((t) => t.kind.equals(kind.apiValue) & t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _decode(row.payloadJson);
  }

  Future<List<LibraryEntryRecord>> list({
    CatalogMediaKind? kind,
    bool includeDeleted = false,
  }) async {
    final query = database.select(database.libraryEntries);
    if (kind != null) query.where((t) => t.kind.equals(kind.apiValue));
    if (!includeDeleted) query.where((t) => t.deletedAt.isNull());
    query.orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return (await query.get()).map((r) => _decode(r.payloadJson)).toList();
  }

  Future<void> put(LibraryEntryRecord record) async {
    await database.into(database.libraryEntries).insertOnConflictUpdate(
          LibraryEntriesCompanion.insert(
            id: record.id,
            kind: record.kind.apiValue,
            payloadJson: jsonEncode(record.toJson()),
            updatedAt: record.updatedAt,
            deletedAt: Value(record.deletedAt),
          ),
        );
  }

  Future<void> putKindJson(
      CatalogMediaKind kind, Map<String, dynamic> json) async {
    if (kind.isUnknown) {
      throw ArgumentError.value(
          kind, 'kind', 'Library entry kind must be known.');
    }
    final rawId = json['id'];
    if (rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException('A library entry requires a non-empty ID.');
    }
    final rawKind = json['kind'];
    if (rawKind != null &&
        (rawKind is! String || catalogMediaKindFromApiValue(rawKind) != kind)) {
      throw FormatException(
        'Library entry kind does not match the $kind persistence boundary.',
      );
    }
    final id = rawId;
    if (json.containsKey('catalog_ref')) {
      throw const FormatException(
        'Local library entries do not support a separate catalog_ref.',
      );
    }
    final existing = await find(kind, id);
    final rawCatalog = json['catalog_data'];
    final catalog = rawCatalog is Map && rawCatalog.isNotEmpty
        ? Map<String, dynamic>.from(rawCatalog)
        : existing?.catalogData;
    if (catalog == null) {
      throw StateError('Cannot save a library entry without its catalog data.');
    }
    final personal = Map<String, dynamic>.from(json)
      ..remove('id')
      ..remove('kind')
      ..remove('catalog_data')
      ..remove('source_catalog_ref')
      ..remove('updated_at')
      ..remove('deleted_at');
    final source = json['source_catalog_ref'];
    if (source != null && source is! Map) {
      throw const FormatException('source_catalog_ref must be an object.');
    }
    await put(LibraryEntryRecord(
      id: id,
      kind: kind,
      catalogData: catalog,
      personalData: {...?existing?.personalData, ...personal},
      sourceCatalogRef: source is Map
          ? CatalogItemRef.fromJson(Map<String, dynamic>.from(source))
          : existing?.sourceCatalogRef,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    ));
  }

  Future<bool> updateCatalog(CatalogItemDto item) async {
    final existing = await find(item.mediaKind, item.id);
    if (existing == null) return false;
    await put(LibraryEntryRecord(
      id: existing.id,
      kind: existing.kind,
      catalogData: item.kindData,
      personalData: existing.personalData,
      sourceCatalogRef: existing.sourceCatalogRef,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: existing.deletedAt,
    ));
    return true;
  }

  Future<void> updatePersonal(
      CatalogMediaKind kind, String id, Map<String, dynamic> values) async {
    final entry = await find(kind, id);
    if (entry == null) throw StateError('Library entry not found.');
    await put(LibraryEntryRecord(
      id: id,
      kind: kind,
      catalogData: entry.catalogData,
      personalData: {...entry.personalData, ...values},
      sourceCatalogRef: entry.sourceCatalogRef,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: entry.deletedAt,
    ));
  }

  LibraryEntryRecord _decode(String raw) => LibraryEntryRecord.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
}
