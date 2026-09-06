import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';

CatalogItem testCatalogItem({
  String id = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  String? displayTitle,
  String? localizedTitle,
  String? originalTitle,
  String? titleExtension,
  List<String>? searchAliases,
  String? synopsis,
  String? coverImageUrl,
  String? thumbnailImageUrl,
  String? coverImageData,
  String? publisher,
  String? barcode,
  String? variant,
  String? country,
  String? language,
  String? ageRating,
  String? itemNumber,
  String? editionTitle,
  String? physicalFormat,
  String? physicalFormatLabel,
  String? sortKey,
  int? releaseYear,
  DateTime? releaseDate,
  List<String>? genres,
  List<String>? platforms,
  List<String>? rawPlatforms,
  List<String>? characters,
  List<String>? storyArcs,
  List<Map<String, dynamic>>? creators,
  List<CatalogEditionDto>? editions,
  List<TrailerLinkDto>? trailerUrls,
  CatalogSeriesDetailsDto? series,
  dynamic video,
  dynamic music,
  dynamic game,
  CatalogPublishingDetailsDto? publishing,
  Map<String, dynamic>? payload,
}) {
  final mergedPayload = <String, dynamic>{
    if (itemNumber != null) 'item_number': itemNumber,
    if (editionTitle != null) 'edition_title': editionTitle,
    if (physicalFormat != null) 'physical_format': physicalFormat,
    if (physicalFormatLabel != null)
      'physical_format_label': physicalFormatLabel,
    if (publisher != null) 'publisher': publisher,
    if (barcode != null) 'barcode': barcode,
    if (variant != null) 'variant': variant,
    if (country != null) 'country': country,
    if (language != null) 'language': language,
    if (ageRating != null) 'age_rating': ageRating,
    if (genres != null) 'genres': genres,
    if (platforms != null || rawPlatforms != null)
      'platforms': platforms ?? rawPlatforms,
    if (rawPlatforms != null) 'raw_platforms': rawPlatforms,
    if (characters != null) 'characters': characters,
    if (storyArcs != null) 'story_arcs': storyArcs,
    if (creators != null) 'creators': creators,
    if (series != null) 'series': series.toJson(),
    if (video != null) 'video': video,
    if (music != null) 'music': music,
    if (game != null) 'game': game,
    if (publishing != null) 'publishing': publishing.toJson(),
    if (payload != null) ...payload,
  };
  final common = CatalogCommonDto(
    title: title,
    displayTitle: displayTitle,
    localizedTitle: localizedTitle,
    originalTitle: originalTitle,
    titleExtension: titleExtension,
    searchAliases: searchAliases,
    synopsis: synopsis,
    coverImageUrl: coverImageUrl,
    thumbnailImageUrl: thumbnailImageUrl,
    coverImageData: coverImageData,
    sortKey: sortKey,
    releaseDate: releaseDate,
    releaseYear: releaseYear,
    editions: editions ?? const [],
    trailerUrls: trailerUrls ?? const [],
  );
  return CatalogItemDto.raw(
    id: id,
    mediaKind: catalogMediaKindFromValue(kind),
    common: common,
    payload: mergedPayload,
  );
}

CatalogItem testCatalogItemFromJson(Map<String, dynamic> json) {
  return testCatalogItemWithKindMetadata(CatalogItem.fromJson(json));
}

CatalogItem testCatalogItemWithKindMetadata(CatalogItem item) {
  if (item.kindMetadata is! Map) return item;
  final payload = item.payload;
  final metadata = switch (item.kind) {
    'anime' => AnimeMetadata.fromJson(payload),
    'boardgame' => BoardGameMetadata.fromJson(payload),
    'book' => BookCatalogMetadata.fromJson(payload),
    'comic' => ComicMedia.fromJson(payload),
    'game' => GameCatalogMetadata.fromJson(payload),
    'manga' => MangaMetadata.fromJson(payload),
    'movie' => MovieCatalogMetadata.fromJson(payload),
    'music' => MusicCatalogMetadata.fromJson(payload),
    'tv' => TvSeriesMetadata.fromJson(payload),
    _ => null,
  };
  return metadata == null ? item : item.withKindMetadata(metadata);
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

AddOwnedItemCommand typedAddOwnedItemCommand({
  required CatalogEntityRef catalogRef,
  required LibraryAddCommonDraft common,
  required OwnedDetailsDraft details,
  OwnedItemCreatePayload? typedPayload,
  PersonalItemAnchor? anchor,
  OwnedItemTrackingDraft? tracking,
}) {
  if (typedPayload != null) {
    return AddOwnedItemCommand(
      catalogRef: catalogRef,
      typedPayload: typedPayload,
      anchor: anchor,
      tracking: tracking,
    );
  }
  final add = libraryKindModuleForKind(
    catalogMediaKindFromApiValue(catalogRef.kind),
  ).add;
  return add.buildCommandFromDetails(
    testCatalogItem(
      id: catalogRef.id,
      kind: catalogRef.kind,
    ),
    LibraryAddCommonDraft(
      condition: common.condition,
      grade: common.grade,
      purchaseDate: common.purchaseDate,
      pricePaidCents: common.pricePaidCents,
      currency: common.currency,
      personalNotes: common.personalNotes,
      quantity: common.quantity,
      tags: common.tags,
      locationId: common.locationId,
      purchaseStore: common.purchaseStore,
      collectionStatus: common.collectionStatus,
      isDigital: common.isDigital,
    ),
    details,
    anchor: anchor,
    tracking: LibraryAddTrackingDraft(
      readStatus: mediaTrackingStatusToStorageValue(tracking?.status),
      rating: tracking?.rating,
      startedAt: tracking?.startedAt,
      finishedAt: tracking?.finishedAt,
      notes: tracking?.notes,
    ),
  );
}

OwnedItem testOwnedItem({
  String id = 'owned-1',
  String itemId = 'test-item-1',
  String kind = 'comic',
  CatalogEntityRef? catalogRef,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool? isDigital,
  PersonalItemAnchor? anchor,
  String? anchorType,
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
      details = MovieOwnedDetails(
        features: features,
        hdrFormats: hdrFormats ?? const <String>[],
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );
    case 'tv':
      details = TvOwnedDetails(
        features: features,
        hdrFormats: hdrFormats ?? const <String>[],
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );
    case 'anime':
      details = AnimeOwnedDetails(
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
    case 'book':
      details = BookOwnedDetails(
        signedBy: signedBy,
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
    anchor: anchor,
    anchorType: anchorType,
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

ShelfEntry testShelfEntry({
  String itemId = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  CatalogItem? catalogItem,
  OwnedItem? ownedItem,
  WishlistItem? wishlistItem,
  TrackingEntry? trackingEntry,
  String? locationPath,
}) {
  final resolvedCatalogItem = catalogItem ??
      testCatalogItem(
        id: itemId,
        kind: kind,
        title: title,
      );
  return ShelfEntry(
    itemId: itemId,
    catalogItem: testCatalogItemWithKindMetadata(resolvedCatalogItem),
    ownedItem: ownedItem,
    wishlistItem: wishlistItem,
    trackingEntry: trackingEntry,
    locationPath: locationPath,
  );
}
