import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/collection_csv/comic_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// Comic's semantic contribution to the generic collection CSV host.
///
/// Collection owns the file format, while Comic owns how its issue, variant,
/// publishing, grading, signature, and key-issue values are represented in
/// that format. The returned lists are serialization cells, not Comic domain
/// objects, so the type-erased boundary exists only at export.
final class ComicCollectionCsvProjection
    with LibraryCollectionCsvProjectionPresentation
    implements
        LibraryCollectionCsvProjection,
        LibraryCollectionCsvOwnedDetailsDecoder {
  const ComicCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  List<String> get clzFriendlyHeader =>
      ComicCollectionCsvImportProfile.clzFriendlyHeader;

  @override
  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const ComicCollectionCsvImportProfile()
        .parseRow(header: header, values: values)
        ?.catalogCells;
  }

  @override
  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const ComicCollectionCsvImportProfile()
        .parseRow(header: header, values: values)
        ?.ownedCells;
  }

  @override
  Map<String, List<String>> get columnAliases => _columnAliases;

  @override
  JsonEncodable? decodeOwnedDetails(List<String> cells) {
    if (cells.isEmpty || cells.length > libraryCollectionCsvOwnedCellCount + 1) {
      return null;
    }
    final grade = _optionalCell(cells[0]);
    final detailCells = [
      ...cells.skip(1),
      ...List<String>.filled(
        libraryCollectionCsvOwnedCellCount - cells.length + 1,
        '',
      ),
    ];
    if (grade == null && !_hasOwnedDetails(detailCells)) return null;
    return _ComicCollectionCsvOwnedImportPayload(
      grade: grade,
      details: ComicOwnedDetails(
        coverPriceCents: int.tryParse(detailCells[0].trim()),
        rawOrSlabbed: _optionalCell(detailCells[1]),
        gradingCompany: _optionalCell(detailCells[2]),
        graderNotes: _optionalCell(detailCells[3]),
        signedBy: _optionalCell(detailCells[4]),
        labelType: _optionalCell(detailCells[5]),
        certificationNumber: _optionalCell(detailCells[6]),
        keyComic: _boolCell(detailCells[7]),
        keyReason: _optionalCell(detailCells[8]),
      ),
    );
  }

  @override
  List<String> catalogCells(ShelfEntry entry) {
    final catalog = entry.catalogItem;
    final comic = catalog == null
        ? null
        : ComicCoreMapper.fromCatalogItem(catalog.toTransportItem());
    return [
      entry.itemId,
      catalog?.kind ?? '',
      comic?.title ?? catalog?.title ?? '',
      comic?.issueNumber ?? '',
      comic?.variantDescription ?? comic?.variant ?? '',
      comic?.editionTitle ?? '',
      comic?.physicalFormat ?? '',
      comic?.physicalFormatLabel ?? '',
      comic?.publisher ?? '',
      _formatDate(comic?.releaseDate ?? comic?.coverDate),
      comic?.barcode ?? '',
    ];
  }

  @override
  String? ownedGrade(ShelfEntry entry) => entry.ownedItem?.grade;

  @override
  List<String> ownedCellsBeforeQuantity(
    ShelfEntry entry, {
    required bool clzFriendly,
  }) {
    final owned = ComicOwnedItemProjection.tryFromOwnedItem(entry.ownedItem);
    final details = owned?.details;
    if (!clzFriendly) return const [];
    return [_formatMoney(details?.coverPriceCents, clzFriendly: true)];
  }

  @override
  List<String> ownedCellsAfterIndex(
    ShelfEntry entry, {
    required bool clzFriendly,
  }) {
    final owned = ComicOwnedItemProjection.tryFromOwnedItem(entry.ownedItem);
    final details = owned?.details;
    return [
      if (!clzFriendly)
        _formatMoney(details?.coverPriceCents, clzFriendly: false),
      details?.rawOrSlabbed ?? '',
      details?.gradingCompany ?? '',
      details?.graderNotes ?? '',
      details?.signedBy ?? '',
      details?.labelType ?? '',
      details?.certificationNumber ?? '',
      details == null ? '' : details.keyComic.toString(),
      details?.keyReason ?? '',
    ];
  }

  String _formatMoney(int? cents, {required bool clzFriendly}) {
    if (cents == null) return '';
    if (!clzFriendly) return cents.toString();
    final absolute = cents.abs();
    final sign = cents < 0 ? '-' : '';
    final whole = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    return '$sign$whole.$fraction';
  }

  bool _hasOwnedDetails(List<String> cells) {
    return cells.asMap().entries.any((entry) {
      if (entry.key == 7) return _boolCell(entry.value);
      return entry.value.trim().isNotEmpty;
    });
  }

  String? _optionalCell(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _boolCell(String value) {
    return switch (value.trim().toLowerCase()) {
      '1' || 'true' || 'yes' || 'y' => true,
      _ => false,
    };
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }

  static const _columnAliases = ComicCollectionCsvImportProfile.columnAliases;

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
}

final class _ComicCollectionCsvOwnedImportPayload implements JsonEncodable {
  const _ComicCollectionCsvOwnedImportPayload({
    required this.grade,
    required this.details,
  });

  final String? grade;
  final ComicOwnedDetails details;

  @override
  Map<String, dynamic> toJson() => {
        ...details.toJson(),
        if (grade != null) 'grade': grade,
      };
}
