import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:uuid/uuid.dart';

String clzImportEntryId(CatalogMediaKind kind, String identity, int copy) =>
    const Uuid().v5(Namespace.url.value,
        'collectarr/import/${kind.apiValue}/clzweb/$identity/$copy');
CollectionImportRow clzImportRow(
    {required CatalogMediaKind kind,
    required String id,
    required String title,
    String? subtitle,
    String? barcode,
    required JsonEncodable catalog,
    required JsonEncodable personal,
    DateTime? createdAt,
    DateTime? updatedAt}) {
  if (title.trim().isEmpty) {
    throw const LibraryImportFormatException(
        'An exported item has no title. Include the Title field and export again.');
  }
  final record = LibraryEntryRecord(
      id: id,
      kind: kind,
      catalogData: catalog.toJson(),
      personalData: {
        ...personal.toJson(),
        if (createdAt != null) 'created_at': createdAt.toUtc().toIso8601String()
      },
      updatedAt: updatedAt ?? DateTime.utc(1970));
  return CollectionImportRow(
      itemId: id,
      status: 'entry',
      mediaKind: kind,
      title: title,
      kindDisplayTitle: title,
      kindDisplaySubtitle: subtitle,
      kindIdentifier: barcode,
      fullEntryPayload: record.toJson());
}
