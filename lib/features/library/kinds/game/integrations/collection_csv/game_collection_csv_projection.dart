import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/collection_csv/game_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// Game's semantic contribution to the generic collection CSV host.
final class GameCollectionCsvProjection
    with
        LibraryCollectionCsvProjectionPresentation,
        LibraryCollectionCsvOwnedImportSupport,
        LibraryCollectionCsvTrackingImport
    implements
        LibraryCollectionCsvProjection,
        LibraryCollectionCsvOwnedDetailsDecoder {
  const GameCollectionCsvProjection();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  TrackingLifecycleCodec get trackingLifecycleCodec => const GameTrackingLifecycleCodec();

  @override
  List<String> get clzFriendlyHeader =>
      GameCollectionCsvImportProfile.clzFriendlyHeader;

  @override
  List<String>? importCatalogCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const GameCollectionCsvImportProfile().importCatalogCells(
      header: header,
      values: values,
    );
  }

  @override
  List<String>? importOwnedCells({
    required List<String> header,
    required List<String> values,
  }) {
    return const GameCollectionCsvImportProfile().importOwnedCells(
      header: header,
      values: values,
    );
  }

  @override
  Map<String, List<String>> get columnAliases =>
      GameCollectionCsvImportProfile.columnAliases;

  @override
  JsonEncodable? decodeOwnedDetails(List<String> cells) {
    if (cells.isEmpty || cells.first.trim().isEmpty) {
      return null;
    }
    return _GameCollectionCsvOwnedImportPayload(cells.first.trim());
  }

  @override
  Object ownedItemFromImportPayload(Map<String, dynamic> payload) =>
      GameOwnedItem.fromJson(payload);

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
        : GameCatalogMetadata.fromJson({
            ...catalog.toSyncPayload(),
            'id': catalog.id,
            'kind': CatalogMediaKind.game.apiValue,
          });
    return [
      entry.itemId,
      catalog?.mediaKind.apiValue ?? '',
      metadata?.title ?? catalog?.title ?? '',
      metadata?.edition ?? '',
      metadata?.platform ?? metadata?.edition ?? '',
      metadata?.edition ?? '',
      metadata?.physicalFormat ?? '',
      metadata?.physicalFormatLabel ?? '',
      metadata?.publishers.firstOrNull ?? '',
      _formatDate(metadata?.releaseDate ?? catalog?.releaseDate),
      metadata?.barcode ?? '',
    ];
  }

  @override
  String? ownedCollectionValue(ShelfEntry entry) {
    final owned = entry.typedOwnedItem;
    return owned is GameOwnedItem ? owned.grade : null;
  }

  @override
  String? ownedCondition(ShelfEntry entry) {
    final owned = entry.typedOwnedItem;
    return owned is GameOwnedItem ? owned.condition : null;
  }

  @override
  int? ownedIndexNumber(ShelfEntry entry) {
    final owned = entry.typedOwnedItem;
    return owned is GameOwnedItem ? owned.indexNumber : null;
  }

  @override
  String? ownedTags(ShelfEntry entry) {
    final owned = entry.typedOwnedItem;
    return owned is GameOwnedItem ? owned.tags : null;
  }

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

final class _GameCollectionCsvOwnedImportPayload implements JsonEncodable {
  const _GameCollectionCsvOwnedImportPayload(this.grade);

  final String grade;

  @override
  Map<String, dynamic> toJson() => {'grade': grade};
}
