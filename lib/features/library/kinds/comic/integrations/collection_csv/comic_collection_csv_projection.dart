import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_library_entry_projection.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/collection_csv/comic_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_catalog_data.dart';

/// Comic's semantic contribution to the generic collection CSV host.
///
/// Collection owns the file format, while Comic owns how its issue, variant,
/// publishing, grading, signature, and key-issue values are represented in
/// that format. The returned lists are serialization cells, not Comic domain
/// objects, so the type-erased boundary exists only at export.
final class ComicCollectionCsvProjection
    with CollectionCsvKindEntryImportSupport
    implements CollectionCsvKindProfile, CollectionCsvEntryCellsDecoder {
  const ComicCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  String importDisplayTitle(List<String> cells) {
    final title = cells.elementAtOrNull(2) ?? '';
    final issue = cells.elementAtOrNull(3) ?? '';
    if (title.trim().isEmpty) return 'Unknown title';
    return issue.trim().isEmpty ? title : '$title #$issue';
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
  List<String> get v1Header => ComicCollectionCsvImportProfile.v1Header;

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
  List<String>? importEntryCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const ComicCollectionCsvImportProfile()
        .parseRow(header: header, values: values)
        ?.entryCells;
  }

  @override
  Map<String, List<String>> get columnAliases => _columnAliases;

  @override
  JsonEncodable? decodeEntryCells(List<String> cells) {
    if (cells.isEmpty || cells.length > collectionCsvV1EntryCellCount + 1) {
      return null;
    }
    final grade = _optionalCell(cells[0]);
    final detailCells = [
      ...cells.skip(1),
      ...List<String>.filled(
        collectionCsvV1EntryCellCount - cells.length + 1,
        '',
      ),
    ];
    if (grade == null && !_hasEntryDetails(detailCells)) return null;
    return _ComicCollectionCsvEntryImportPayload(
      grade: grade,
      details: ComicEntryDetails(
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
  List<String> catalogCells(LibraryWorkspaceSource entry) {
    final catalog = entry.catalogData;
    final comic = catalog is ComicWorkspaceCatalogData ? catalog.comic : null;
    return [
      entry.itemId,
      CatalogMediaKind.comic.apiValue,
      comic?.title ?? entry.title,
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
  String? entryCollectionValue(LibraryWorkspaceSource entry) =>
      ComicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch)
          ?.personal
          .grade;

  @override
  String? entryCondition(LibraryWorkspaceSource entry) =>
      ComicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch)
          ?.personal
          .condition;

  @override
  int? entryIndexNumber(LibraryWorkspaceSource entry) =>
      ComicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch)
          ?.personal
          .indexNumber;

  @override
  String? entryTags(LibraryWorkspaceSource entry) =>
      ComicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch)
          ?.personal
          .tags;

  @override
  List<String> entryCellsBeforeLocation(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  }) {
    final personalState =
        ComicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch);
    final details = personalState?.personal.details;
    if (!clzFriendly) return const [];
    return [_formatMoney(details?.coverPriceCents, clzFriendly: true)];
  }

  @override
  List<String> entryCellsAfterIndex(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  }) {
    final personalState =
        ComicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch);
    final details = personalState?.personal.details;
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

  bool _hasEntryDetails(List<String> cells) {
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
  CatalogImportTransport? catalogTransportFromImportCells(List<String> cells) {
    if (cells.length != collectionCsvV1CatalogCellCount ||
        cells[0].trim().isEmpty) {
      return null;
    }
    return CatalogImportTransport.fromPayload({
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
    });
  }
}

final class _ComicCollectionCsvEntryImportPayload implements JsonEncodable {
  const _ComicCollectionCsvEntryImportPayload({
    required this.grade,
    required this.details,
  });

  final String? grade;
  final ComicEntryDetails details;

  @override
  Map<String, dynamic> toJson() => {
        ...details.toJson(),
        if (grade != null) 'grade': grade,
      };
}
