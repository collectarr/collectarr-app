import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/collection_csv/boardgame_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// BoardGame's semantic contribution to the generic collection CSV host.
final class BoardGameCollectionCsvProjection
    with LibraryCollectionCsvProjectionPresentation
    implements
        LibraryCollectionCsvProjection,
        LibraryCollectionCsvOwnedDetailsDecoder {
  const BoardGameCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  List<String> get clzFriendlyHeader =>
      BoardGameCollectionCsvImportProfile.clzFriendlyHeader;

  @override
  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const BoardGameCollectionCsvImportProfile().importCatalogCells(
      header: header,
      values: values,
    );
  }

  @override
  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const BoardGameCollectionCsvImportProfile().importOwnedCells(
      header: header,
      values: values,
    );
  }

  @override
  Map<String, List<String>> get columnAliases =>
      BoardGameCollectionCsvImportProfile.columnAliases;

  @override
  JsonEncodable? decodeOwnedDetails(List<String> cells) {
    if (cells.isEmpty ||
        cells.first.trim().isEmpty) {
      return null;
    }
    return _BoardGameCollectionCsvOwnedImportPayload(cells.first.trim());
  }

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
  List<String> catalogCells(ShelfEntry entry) {
    final catalog = entry.catalogItem;
    final metadata = catalog == null
        ? null
        : BoardGameMetadata.fromJson({
            ...catalog.toSyncPayload(),
            'id': catalog.id,
            'kind': CatalogMediaKind.boardgame.apiValue,
          });
    return [
      entry.itemId,
      catalog?.kind ?? '',
      metadata?.title ?? catalog?.title ?? '',
      metadata?.itemNumber ?? '',
      metadata?.variant ?? '',
      '',
      metadata?.physicalFormat ?? '',
      metadata?.physicalFormatLabel ?? '',
      metadata?.publisher ?? metadata?.publishers.firstOrNull ?? '',
      _formatDate(catalog?.releaseDate),
      metadata?.barcode ?? '',
    ];
  }

  @override
  String? ownedGrade(ShelfEntry entry) => entry.ownedItem?.grade;

  @override
  List<String> ownedCellsBeforeQuantity(
    ShelfEntry entry, {
    required bool clzFriendly,
  }) {
    return clzFriendly ? const [''] : const [];
  }

  @override
  List<String> ownedCellsAfterIndex(
    ShelfEntry entry, {
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

final class _BoardGameCollectionCsvOwnedImportPayload implements JsonEncodable {
  const _BoardGameCollectionCsvOwnedImportPayload(this.grade);

  final String grade;

  @override
  Map<String, dynamic> toJson() => {'grade': grade};
}
