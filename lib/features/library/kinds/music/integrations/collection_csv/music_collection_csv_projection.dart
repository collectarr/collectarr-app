import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/collection_csv/music_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';

/// Music's semantic contribution to the generic collection CSV host.
///
/// Music exports album-level values. Track hierarchy and listening state
/// remain personalState by Music and are intentionally not flattened into the
/// generic collection row.
final class MusicCollectionCsvProjection
    with CollectionCsvKindEntryImportSupport
    implements CollectionCsvKindProfile, CollectionCsvEntryCellsDecoder {
  const MusicCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  String importDisplayTitle(List<String> cells) {
    final title = cells.elementAtOrNull(2) ?? '';
    final release = cells.elementAtOrNull(3) ?? '';
    if (title.trim().isEmpty) return 'Unknown title';
    return release.trim().isEmpty ? title : '$title #$release';
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
  List<String> get v1Header => MusicCollectionCsvImportProfile.v1Header;

  @override
  List<String> get clzFriendlyHeader =>
      MusicCollectionCsvImportProfile.clzFriendlyHeader;

  @override
  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const MusicCollectionCsvImportProfile().importCatalogCells(
      header: header,
      values: values,
    );
  }

  @override
  List<String>? importEntryCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const MusicCollectionCsvImportProfile().importEntryCells(
      header: header,
      values: values,
    );
  }

  @override
  Map<String, List<String>> get columnAliases =>
      MusicCollectionCsvImportProfile.columnAliases;

  @override
  JsonEncodable? decodeEntryCells(List<String> cells) {
    if (cells.isEmpty || cells.first.trim().isEmpty) {
      return null;
    }
    return _MusicCollectionCsvEntryImportPayload(cells.first.trim());
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
      if (cells[3].trim().isNotEmpty) 'catalog_number': cells[3],
      if (cells[5].trim().isNotEmpty) 'subtitle': cells[5],
      if (cells[6].trim().isNotEmpty) 'format': cells[6],
      if (cells[8].trim().isNotEmpty) 'label': cells[8],
      if (cells[9].trim().isNotEmpty) 'release_date': cells[9],
      if (cells[10].trim().isNotEmpty) 'barcode': cells[10],
    });
  }

  @override
  List<String> catalogCells(LibraryWorkspaceSource entry) {
    final catalog = entry.catalogData;
    final music = catalog is MusicWorkspaceCatalogData ? catalog.music : null;
    final release = catalog is MusicWorkspaceCatalogData ? catalog.music : null;
    final format = release?.format ?? '';
    return [
      entry.itemId,
      CatalogMediaKind.music.apiValue,
      music?.title ?? entry.title,
      release?.catalogNumber ?? '',
      '',
      release?.subtitle ?? '',
      format,
      format,
      release?.publisher ?? music?.studios.join(', ') ?? '',
      _formatDate(
        music?.originalReleaseDate ??
            release?.releaseDate ??
            music?.releaseDate ??
            entry.catalogData?.releaseDate,
      ),
      release?.barcode ?? '',
    ];
  }

  @override
  String? entryCollectionValue(LibraryWorkspaceSource entry) {
    final personalState =
        MusicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch);
    return personalState is MusicLibraryEntry
        ? personalState.personal.grade
        : null;
  }

  @override
  String? entryCondition(LibraryWorkspaceSource entry) {
    final personalState =
        MusicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch);
    return personalState is MusicLibraryEntry
        ? personalState.personal.condition
        : null;
  }

  @override
  int? entryIndexNumber(LibraryWorkspaceSource entry) {
    final personalState =
        MusicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch);
    return personalState is MusicLibraryEntry
        ? personalState.personal.indexNumber
        : null;
  }

  @override
  String? entryTags(LibraryWorkspaceSource entry) {
    final personalState =
        MusicLibraryEntryProjection.fromDispatch(entry.libraryEntryDispatch);
    return personalState is MusicLibraryEntry
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

final class _MusicCollectionCsvEntryImportPayload implements JsonEncodable {
  const _MusicCollectionCsvEntryImportPayload(this.grade);

  final String grade;

  @override
  Map<String, dynamic> toJson() => {'grade': grade};
}
