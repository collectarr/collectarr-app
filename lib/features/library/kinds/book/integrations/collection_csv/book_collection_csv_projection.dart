import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/collection_csv/book_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// Book's semantic contribution to the generic collection CSV host.
final class BookCollectionCsvProjection
    with
        LibraryCollectionCsvOwnedImportSupport,
        LibraryCollectionCsvTrackingImport
    implements
        LibraryCollectionCsvProjection,
        LibraryCollectionCsvOwnedDetailsDecoder {
  const BookCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  String importDisplayTitle(List<String> cells) {
    final title = cells.elementAtOrNull(2) ?? '';
    final edition = cells.elementAtOrNull(3) ?? '';
    if (title.trim().isEmpty) return 'Unknown title';
    return edition.trim().isEmpty ? title : '$title #$edition';
  }

  @override
  String importDisplaySubtitle(List<String> cells) => [
        if ((cells.elementAtOrNull(4) ?? '').trim().isNotEmpty)
          cells.elementAtOrNull(4),
        if ((cells.elementAtOrNull(8) ?? '').trim().isNotEmpty)
          cells.elementAtOrNull(8),
        if ((cells.elementAtOrNull(9) ?? '').trim().isNotEmpty)
          cells.elementAtOrNull(9),
        if ((cells.elementAtOrNull(10) ?? '').trim().isNotEmpty)
          cells.elementAtOrNull(10),
      ].join(' | ');

  @override
  String? importPrimaryLookupValue(List<String> cells) {
    final value = cells.elementAtOrNull(3)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  @override
  String? importBarcode(List<String> cells) {
    final value = cells.elementAtOrNull(10)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  @override
  TrackingLifecycleCodec get trackingLifecycleCodec =>
      const BookTrackingLifecycleCodec();

  @override
  List<String> get clzFriendlyHeader =>
      BookCollectionCsvImportProfile.clzFriendlyHeader;

  @override
  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const BookCollectionCsvImportProfile().importCatalogCells(
      header: header,
      values: values,
    );
  }

  @override
  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const BookCollectionCsvImportProfile().importOwnedCells(
      header: header,
      values: values,
    );
  }

  @override
  Map<String, List<String>> get columnAliases =>
      BookCollectionCsvImportProfile.columnAliases;

  @override
  JsonEncodable? decodeOwnedDetails(List<String> cells) {
    if (cells.isEmpty || cells.first.trim().isEmpty) {
      return null;
    }
    return _BookCollectionCsvOwnedImportPayload(cells.first.trim());
  }

  @override
  Object ownedItemFromImportPayload(Map<String, dynamic> payload) =>
      BookOwnedItem.fromJson(payload);

  @override
  CatalogImportSnapshot? catalogItemFromImportCells(List<String> cells) {
    if (cells.length != libraryCollectionCsvCatalogCellCount ||
        cells[0].trim().isEmpty) {
      return null;
    }
    return CatalogImportSnapshot.fromItem(CatalogItemDto.fromJson({
      'id': cells[0],
      'kind': kind.apiValue,
      'title': cells[2],
      if (cells[3].trim().isNotEmpty) 'item_number': cells[3],
      if (cells[4].trim().isNotEmpty) 'variant': cells[4],
      if (cells[5].trim().isNotEmpty) 'edition_title': cells[5],
      if (cells[6].trim().isNotEmpty) 'physical_format': cells[6],
      if (cells[7].trim().isNotEmpty) 'physical_format_label': cells[7],
      if (cells[8].trim().isNotEmpty) 'publisher': cells[8],
      if (cells[9].trim().isNotEmpty) 'release_date': cells[9],
      if (cells[10].trim().isNotEmpty) 'barcode': cells[10],
    }));
  }

  @override
  List<String> catalogCells(LibraryWorkspaceSource entry) {
    final catalog = entry.catalogTransport;
    final metadata = catalog == null
        ? null
        : BookCatalogMetadata.fromJson({
            ...catalog.mapTransport((transport) => transport.toSyncPayload()),
            'id': catalog.id,
            'kind': CatalogMediaKind.book.apiValue,
          });
    return [
      entry.itemId,
      catalog?.mediaKind.apiValue ?? '',
      metadata?.title ?? catalog?.title ?? '',
      metadata?.itemNumber ?? '',
      metadata?.variant ?? '',
      metadata?.editionTitle ?? '',
      metadata?.physicalFormat ?? '',
      metadata?.physicalFormatLabel ?? '',
      metadata?.publisher ?? '',
      _formatDate(catalog?.releaseDate),
      metadata?.barcode ?? '',
    ];
  }

  @override
  String? ownedCollectionValue(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is BookOwnedItem ? owned.grade : null;
  }

  @override
  String? ownedCondition(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is BookOwnedItem ? owned.condition : null;
  }

  @override
  int? ownedIndexNumber(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is BookOwnedItem ? owned.indexNumber : null;
  }

  @override
  String? ownedTags(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is BookOwnedItem ? owned.tags : null;
  }

  @override
  List<String> ownedCellsBeforeQuantity(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  }) {
    return clzFriendly ? const [''] : const [];
  }

  @override
  List<String> ownedCellsAfterIndex(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  }) {
    return List<String>.filled(
      clzFriendly
          ? libraryCollectionCsvOwnedCellCount - 1
          : libraryCollectionCsvOwnedCellCount,
      '',
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }
}

final class _BookCollectionCsvOwnedImportPayload implements JsonEncodable {
  const _BookCollectionCsvOwnedImportPayload(this.grade);

  final String grade;

  @override
  Map<String, dynamic> toJson() => {'grade': grade};
}
