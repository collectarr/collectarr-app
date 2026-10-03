import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_library_entry_projection.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/collection_csv/boardgame_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_catalog_data.dart';

/// BoardGame's semantic contribution to the generic collection CSV host.
final class BoardGameCollectionCsvProjection
    with CollectionCsvKindEntryImportSupport
    implements CollectionCsvKindProfile, CollectionCsvEntryCellsDecoder {
  const BoardGameCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

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
  List<String> get v1Header => BoardGameCollectionCsvImportProfile.v1Header;

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
  List<String>? importEntryCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const BoardGameCollectionCsvImportProfile().importEntryCells(
      header: header,
      values: values,
    );
  }

  @override
  Map<String, List<String>> get columnAliases =>
      BoardGameCollectionCsvImportProfile.columnAliases;

  @override
  JsonEncodable? decodeEntryCells(List<String> cells) {
    if (cells.isEmpty || cells.first.trim().isEmpty) {
      return null;
    }
    return _BoardGameCollectionCsvEntryImportPayload(cells.first.trim());
  }

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

  @override
  List<String> catalogCells(LibraryWorkspaceSource entry) {
    final catalog = entry.catalogData;
    final metadata =
        catalog is BoardGameWorkspaceCatalogData ? catalog.metadata : null;
    final boardgame =
        catalog is BoardGameWorkspaceCatalogData ? catalog.boardgame : null;
    return [
      entry.itemId,
      CatalogMediaKind.boardgame.apiValue,
      metadata?.title ?? boardgame?.title ?? entry.title,
      metadata?.itemNumber ?? '',
      metadata?.variant ?? '',
      '',
      metadata?.physicalFormat ?? '',
      metadata?.physicalFormatLabel ?? '',
      metadata?.publisher ?? metadata?.publishers.firstOrNull ?? '',
      _formatDate(boardgame?.releaseDate ?? entry.catalogData?.releaseDate),
      metadata?.barcode ?? '',
    ];
  }

  @override
  String? entryCollectionValue(LibraryWorkspaceSource entry) {
    final personalState = BoardGameLibraryEntryProjection.fromDispatch(
        entry.libraryEntryDispatch);
    return personalState is BoardGameLibraryEntry
        ? personalState.personal.grade
        : null;
  }

  @override
  String? entryCondition(LibraryWorkspaceSource entry) {
    final personalState = BoardGameLibraryEntryProjection.fromDispatch(
        entry.libraryEntryDispatch);
    return personalState is BoardGameLibraryEntry
        ? personalState.personal.condition
        : null;
  }

  @override
  int? entryIndexNumber(LibraryWorkspaceSource entry) {
    final personalState = BoardGameLibraryEntryProjection.fromDispatch(
        entry.libraryEntryDispatch);
    return personalState is BoardGameLibraryEntry
        ? personalState.personal.indexNumber
        : null;
  }

  @override
  String? entryTags(LibraryWorkspaceSource entry) {
    final personalState = BoardGameLibraryEntryProjection.fromDispatch(
        entry.libraryEntryDispatch);
    return personalState is BoardGameLibraryEntry
        ? personalState.personal.tags
        : null;
  }

  @override
  List<String> entryCellsBeforeLocation(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  }) {
    return const [];
  }

  @override
  List<String> entryCellsAfterIndex(
    LibraryWorkspaceSource entry, {
    required bool clzFriendly,
  }) {
    return List<String>.filled(
      collectionCsvV1EntryCellCount,
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

final class _BoardGameCollectionCsvEntryImportPayload implements JsonEncodable {
  const _BoardGameCollectionCsvEntryImportPayload(this.grade);

  final String grade;

  @override
  Map<String, dynamic> toJson() => {'grade': grade};
}
