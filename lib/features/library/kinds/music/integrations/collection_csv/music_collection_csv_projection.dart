import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/collection_csv/music_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// Music's semantic contribution to the generic collection CSV host.
///
/// Music exports release-level values. Track hierarchy and listening state
/// remain owned by Music and are intentionally not flattened into the
/// generic collection row.
final class MusicCollectionCsvProjection
    with
        LibraryCollectionCsvProjectionPresentation,
        LibraryCollectionCsvOwnedImportSupport,
        LibraryCollectionCsvTrackingImport
    implements
        LibraryCollectionCsvProjection,
        LibraryCollectionCsvOwnedDetailsDecoder {
  const MusicCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  TrackingLifecycleCodec get trackingLifecycleCodec =>
      const MusicTrackingLifecycleCodec();

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
  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const MusicCollectionCsvImportProfile().importOwnedCells(
      header: header,
      values: values,
    );
  }

  @override
  Map<String, List<String>> get columnAliases =>
      MusicCollectionCsvImportProfile.columnAliases;

  @override
  JsonEncodable? decodeOwnedDetails(List<String> cells) {
    if (cells.isEmpty || cells.first.trim().isEmpty) {
      return null;
    }
    return _MusicCollectionCsvOwnedImportPayload(cells.first.trim());
  }

  @override
  Object ownedItemFromImportPayload(Map<String, dynamic> payload) =>
      MusicOwnedItem.fromJson(payload);

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
        : MusicCatalogMetadata.fromJson({
            ...catalog.toSyncPayload(),
            'id': catalog.id,
            'kind': CatalogMediaKind.music.apiValue,
          });
    final release = metadata?.releases.firstOrNull;
    return [
      entry.itemId,
      catalog?.mediaKind.apiValue ?? '',
      metadata?.title ?? catalog?.title ?? '',
      release?.catalogNumber ?? '',
      metadata?.variant ?? release?.format ?? '',
      metadata?.editionTitle ?? '',
      metadata?.physicalFormat ?? '',
      metadata?.physicalFormatLabel ?? '',
      metadata?.recordLabel ?? metadata?.publisher ?? metadata?.studio ?? '',
      _formatDate(
        metadata?.originalReleaseDate ??
            release?.releaseDate ??
            catalog?.releaseDate,
      ),
      metadata?.barcode ?? release?.barcode ?? '',
    ];
  }

  @override
  String? ownedCollectionValue(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is MusicOwnedItem ? owned.grade : null;
  }

  @override
  String? ownedCondition(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is MusicOwnedItem ? owned.condition : null;
  }

  @override
  int? ownedIndexNumber(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is MusicOwnedItem ? owned.indexNumber : null;
  }

  @override
  String? ownedTags(LibraryWorkspaceSource entry) {
    final owned = entry.typedOwnedItem;
    return owned is MusicOwnedItem ? owned.tags : null;
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

final class _MusicCollectionCsvOwnedImportPayload implements JsonEncodable {
  const _MusicCollectionCsvOwnedImportPayload(this.grade);

  final String grade;

  @override
  Map<String, dynamic> toJson() => {'grade': grade};
}
