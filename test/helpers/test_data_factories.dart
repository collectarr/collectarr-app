import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';

/// Builds a [CatalogItem] with sensible defaults for testing.
///
/// Only [id] and [title] are required. Override any field via named parameters.
CatalogItem testCatalogItem({
  String id = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  String? displayTitle,
  String? synopsis,
  String? coverImageUrl,
  String? thumbnailImageUrl,
  String? coverImageData,
  String? publisher,
  String? barcode,
  String? variant,
  String? itemNumber,
  String? editionTitle,
  String? physicalFormat,
  String? physicalFormatLabel,
  String? sortKey,
  int? releaseYear,
  DateTime? releaseDate,
  List<String>? genres,
  List<String>? characters,
  List<String>? storyArcs,
  List<Map<String, dynamic>>? creators,
  List<CatalogEdition>? editions,
  CatalogSeriesDetails? series,
  VideoCatalogDetails? video,
  MusicCatalogDetails? music,
  GameCatalogDetails? game,
  CatalogPublishingDetails? publishing,
}) {
  return CatalogItem(
    id: id,
    kind: kind,
    title: title,
    displayTitle: displayTitle,
    synopsis: synopsis,
    coverImageUrl: coverImageUrl,
    thumbnailImageUrl: thumbnailImageUrl,
    coverImageData: coverImageData,
    publisher: publisher,
    barcode: barcode,
    variant: variant,
    itemNumber: itemNumber,
    editionTitle: editionTitle,
    physicalFormat: physicalFormat,
    physicalFormatLabel: physicalFormatLabel,
    sortKey: sortKey,
    releaseYear: releaseYear,
    releaseDate: releaseDate,
    genres: genres,
    characters: characters,
    storyArcs: storyArcs,
    creators: creators,
    editions: editions,
    series: series,
    video: video,
    music: music,
    game: game,
    publishing: publishing,
  );
}

/// Builds an [OwnedItem] with sensible defaults for testing.
OwnedItem testOwnedItem({
  String id = 'owned-1',
  String itemId = 'test-item-1',
  DateTime? updatedAt,
  bool? isDigital,
  String? condition,
  String? grade,
  DateTime? purchaseDate,
  int? pricePaidCents,
  String? currency,
  String? personalNotes,
  int quantity = 1,
  String? storageBox,
  int? indexNumber,
  int? rating,
  String? readStatus,
  DateTime? startedAt,
  DateTime? finishedAt,
  String? tags,
  String? locationId,
  String? editionId,
  String? variantId,
}) {
  return OwnedItem(
    id: id,
    itemId: itemId,
    updatedAt: updatedAt ?? DateTime.utc(2025, 1, 1),
    isDigital: isDigital,
    condition: condition,
    grade: grade,
    purchaseDate: purchaseDate,
    pricePaidCents: pricePaidCents,
    currency: currency,
    personalNotes: personalNotes,
    quantity: quantity,
    storageBox: storageBox,
    indexNumber: indexNumber,
    rating: rating,
    readStatus: readStatus,
    startedAt: startedAt,
    finishedAt: finishedAt,
    tags: tags,
    locationId: locationId,
    editionId: editionId,
    variantId: variantId,
  );
}

/// Builds a [ShelfEntry] with sensible defaults for testing.
///
/// If [catalogItem] is omitted, a default one is created from [itemId] and
/// [kind].
ShelfEntry testShelfEntry({
  String itemId = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  CatalogItem? catalogItem,
  OwnedItem? ownedItem,
  String? locationPath,
}) {
  return ShelfEntry(
    itemId: itemId,
    catalogItem: catalogItem ??
        testCatalogItem(id: itemId, kind: kind, title: title),
    ownedItem: ownedItem,
    locationPath: locationPath,
  );
}
