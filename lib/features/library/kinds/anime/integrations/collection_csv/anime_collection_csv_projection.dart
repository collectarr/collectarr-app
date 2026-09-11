import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/integrations/collection_csv/anime_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// Anime's semantic contribution to the generic collection CSV host.
///
/// Anime owns the meaning of its series, edition/format, studio and UPC
/// values. Episode and season hierarchy stays in Anime's typed graph.
final class AnimeCollectionCsvProjection
    with
        LibraryCollectionCsvOwnedImportSupport,
        LibraryCollectionCsvTrackingImport
    implements
        LibraryCollectionCsvProjection,
        LibraryCollectionCsvOwnedDetailsDecoder {
  const AnimeCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  String importDisplayTitle(List<String> cells) {
    final title = cells.elementAtOrNull(2) ?? '';
    final volume = cells.elementAtOrNull(3) ?? '';
    if (title.trim().isEmpty) return 'Unknown title';
    return volume.trim().isEmpty ? title : '$title #$volume';
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
      const AnimeTrackingLifecycleCodec();

  @override
  List<String> get clzFriendlyHeader =>
      AnimeCollectionCsvImportProfile.clzFriendlyHeader;

  @override
  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const AnimeCollectionCsvImportProfile().importCatalogCells(
      header: header,
      values: values,
    );
  }

  @override
  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const AnimeCollectionCsvImportProfile().importOwnedCells(
      header: header,
      values: values,
    );
  }

  @override
  Map<String, List<String>> get columnAliases =>
      AnimeCollectionCsvImportProfile.columnAliases;

  @override
  JsonEncodable? decodeOwnedDetails(List<String> cells) {
    if (cells.isEmpty || cells.first.trim().isEmpty) {
      return null;
    }
    return _AnimeCollectionCsvOwnedImportPayload(cells.first.trim());
  }

  @override
  Object ownedItemFromImportPayload(Map<String, dynamic> payload) =>
      AnimeOwnedItem.fromJson(payload);

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
        : AnimeMetadata.fromJson({
            ...catalog.toSyncPayload(),
            'id': catalog.id,
            'kind': CatalogMediaKind.anime.apiValue,
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
      metadata?.publisher ?? metadata?.studios.firstOrNull ?? '',
      _formatDate(metadata?.startDate ?? catalog?.releaseDate),
      metadata?.barcode ?? '',
    ];
  }

  @override
  String? ownedCollectionValue(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is AnimeOwnedItem ? owned.grade : null;
  }

  @override
  String? ownedCondition(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is AnimeOwnedItem ? owned.condition : null;
  }

  @override
  int? ownedIndexNumber(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is AnimeOwnedItem ? owned.indexNumber : null;
  }

  @override
  String? ownedTags(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is AnimeOwnedItem ? owned.tags : null;
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

final class _AnimeCollectionCsvOwnedImportPayload implements JsonEncodable {
  const _AnimeCollectionCsvOwnedImportPayload(this.grade);

  final String grade;

  @override
  Map<String, dynamic> toJson() => {'grade': grade};
}
