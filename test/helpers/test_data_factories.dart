import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';

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
    publisher: publisher ?? (kind == 'comic' ? 'IDW' : null),
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
    creators: creators ?? (kind == 'book' ? const [{'name': 'J.R.R. Tolkien', 'role': 'Author'}] : null),
    editions: editions,
    series: series,
    video: video,
    music: music,
    game: game,
    publishing: publishing ?? (kind == 'comic' ? const CatalogPublishingDetails(imprint: 'IDW', subtitle: 'Director Cut') : null),
  );
}

CatalogEntityRef testCatalogRef(
  String id, {
  String kind = 'unknown',
  CatalogEntityType entityType = CatalogEntityType.work,
}) {
  return CatalogEntityRef(
    kind: kind,
    entityType: entityType,
    id: id,
  );
}

/// Builds an [OwnedItem] with sensible defaults for testing.
OwnedItem testOwnedItem({
  String id = 'owned-1',
  String itemId = 'test-item-1',
  String kind = 'comic',
  CatalogEntityRef? catalogRef,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool? isDigital,
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
  String? condition,
  String? grade,
  DateTime? purchaseDate,
  int? pricePaidCents,
  String? currency,
  String? personalNotes,
  int quantity = 1,
  int? indexNumber,
  int? coverPriceCents,
  String? rawOrSlabbed,
  String? gradingCompany,
  String? graderNotes,
  String? signedBy,
  String? labelType,
  String? customLabel,
  String? pageQuality,
  String? certificationNumber,
  bool keyComic = false,
  String? keyReason,
  String? keyCategory,
  String? keySeverity,
  int? rating,
  String? readStatus,
  DateTime? startedAt,
  DateTime? finishedAt,
  String? tags,
  DateTime? deletedAt,
  DateTime? soldAt,
  int? sellPriceCents,
  String? soldTo,
  String? ownerUserId,
  String? ownerLabel,
  String? locationId,
  String? features,
  List<String>? hdrFormats,
  String? purchaseStore,
  String? boxSetId,
  String? boxSetName,
  String? storageDevice,
  String? storageSlot,
  String? region,
  String? packaging,
  String? distributor,
  String? collectionStatus,
  DateTime? lastBagBoardDate,
  int? marketValueCents,
  String? gameCompleteness,
  bool? gameHasBox,
  bool? gameHasManual,
  String? gamePriceChartingId,
  String? gameCoreRegion,
  bool? gameValueIsLocked,
}) {
  final resolvedCatalogRef = catalogRef ??
      CatalogEntityRef(
        kind: kind,
        entityType: CatalogEntityType.ownedCopy,
        id: itemId,
      );

  OwnedItemDetails details;
  switch (resolvedCatalogRef.kind) {
    case 'comic':
    case 'manga':
      details = ComicOwnedDetails(
        rawOrSlabbed: rawOrSlabbed,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        signedBy: signedBy,
        labelType: labelType,
        customLabel: customLabel,
        pageQuality: pageQuality,
        certificationNumber: certificationNumber,
        keyComic: keyComic,
        keyReason: keyReason,
        keyCategory: keyCategory,
        keySeverity: keySeverity,
        coverPriceCents: coverPriceCents,
        lastBagBoardDate: lastBagBoardDate,
      );
    case 'movie':
    case 'tv':
    case 'anime':
      details = coverPriceCents != null
          ? ComicOwnedDetails(coverPriceCents: coverPriceCents)
          : VideoOwnedDetails(
              features: features,
              hdrFormats: hdrFormats ?? const <String>[],
              boxSetId: boxSetId,
              boxSetName: boxSetName,
              region: region,
              packaging: packaging,
              distributor: distributor,
            );
    case 'game':
      details = GameOwnedDetails(
        completeness: gameCompleteness,
        hasBox: gameHasBox,
        hasManual: gameHasManual,
        priceChartingId: gamePriceChartingId,
        coreRegion: gameCoreRegion,
        valueIsLocked: gameValueIsLocked,
      );
    case 'music':
      details = MusicOwnedDetails(
        storageDevice: storageDevice,
        storageSlot: storageSlot,
      );
    default:
      details = const GenericOwnedDetails();
  }

  return OwnedItem(
    id: id,
    catalogRef: resolvedCatalogRef,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.utc(2025, 1, 1),
    isDigital: isDigital,
    editionId: editionId,
    variantId: variantId,
    bundleReleaseId: bundleReleaseId,
    details: details,
    condition: condition,
    grade: grade,
    purchaseDate: purchaseDate,
    pricePaidCents: pricePaidCents,
    currency: currency,
    personalNotes: personalNotes,
    quantity: quantity,
    indexNumber: indexNumber,
    rating: rating,
    readStatus: readStatus,
    startedAt: startedAt,
    finishedAt: finishedAt,
    tags: tags,
    deletedAt: deletedAt,
    soldAt: soldAt,
    sellPriceCents: sellPriceCents,
    soldTo: soldTo,
    ownerUserId: ownerUserId,
    ownerLabel: ownerLabel,
    locationId: locationId,
    purchaseStore: purchaseStore,
    collectionStatus: collectionStatus,
    marketValueCents: marketValueCents,
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
  final resolvedCatalogItem = catalogItem ?? testCatalogItem(
    id: itemId,
    kind: kind,
    title: title,
  );
  return ShelfEntry(
    itemId: itemId,
    catalogItem: LibraryMetadataItem.fromCatalogItem(resolvedCatalogItem),
    ownedItem: ownedItem,
    locationPath: locationPath,
  );
}

LibraryProjectionRuntime testProjectionItem({
  String? id,
  String itemId = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  String? barcode,
  CatalogItem? catalogItem,
  OwnedItem? ownedItem,
  String? locationPath,
}) {
  final resolvedId = id ?? itemId;
  final shelf = testShelfEntry(
    itemId: resolvedId,
    kind: kind,
    title: title,
    catalogItem: catalogItem ?? testCatalogItem(id: resolvedId, kind: kind, title: title, barcode: barcode),
    ownedItem: ownedItem,
    locationPath: locationPath,
  );
  final node = LibraryTitleNodeRef(titleItemId: resolvedId);
  final dto = const GenericWorkspaceProjector().projectTitle(
    source: shelf,
    node: node,
  );
  return LibraryProjectionItem(
    source: shelf,
    node: node,
    dto: dto,
  );
}

WishlistItem testWishlistItem({
  String id = 'wish-1',
  required String itemId,
  String kind = 'comic',
  DateTime? updatedAt,
}) {
  final dt = updatedAt ?? DateTime.utc(2026, 1, 1);
  return WishlistItem(
    id: id,
    catalogRef: testCatalogRef(itemId, kind: kind),
    createdAt: dt,
    updatedAt: dt,
  );
}

