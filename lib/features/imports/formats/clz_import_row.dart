import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/imports/framework/library_guided_importer.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:uuid/uuid.dart';

/// Stable local entry IDs for one CLZ import: repeated copies of the same
/// source identity are numbered in file order, so importing the same file
/// again updates the same entries instead of adding duplicates.
final class ClzImportIdentities {
  ClzImportIdentities(this.kind);

  final CatalogMediaKind kind;
  final _copies = <String, int>{};

  String next(String identity) {
    final copy =
        _copies.update(identity, (count) => count + 1, ifAbsent: () => 1);
    return const Uuid().v5(Namespace.url.value,
        'collectarr/import/${kind.apiValue}/clzweb/$identity/$copy');
  }
}

CollectionImportRow clzImportRow(
    {required CatalogMediaKind kind,
    required String id,
    required String title,
    String? barcode,
    required JsonEncodable catalog,
    required JsonEncodable personal,
    DateTime? createdAt,
    DateTime? updatedAt,
    CollectionImportLoan? loan,
    Map<String, String?> customFieldValues = const {}}) {
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
      kindIdentifier: barcode,
      customFieldValues: customFieldValues,
      loan: loan,
      fullEntryPayload: record.toJson());
}
