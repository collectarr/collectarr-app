import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/test/helpers/test_owned_item_fixture.dart';

export 'package:collectarr_app/test/helpers/test_owned_item_fixture.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/catalog_reference_helpers.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';

export 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';

final class _CatalogFixtureDefaults {
  const _CatalogFixtureDefaults({
    this.publisher,
    this.creators,
    this.publishing,
  });

  final String? publisher;
  final List<Map<String, dynamic>>? creators;
  final CatalogPublishingDetailsDto? publishing;
}

const _catalogFixtureDefaults = <CatalogMediaKind, _CatalogFixtureDefaults>{
  CatalogMediaKind.book: _CatalogFixtureDefaults(
    creators: [
      {'name': 'J.R.R. Tolkien', 'role': 'Author'},
    ],
  ),
  CatalogMediaKind.comic: _CatalogFixtureDefaults(
    publisher: 'IDW',
    publishing: CatalogPublishingDetailsDto(
      imprint: 'IDW',
      subtitle: 'Director Cut',
    ),
  ),
};

/// Builds a [CatalogItemDto] with sensible defaults for testing.
///
/// Only [id] and [title] are required. Override any field via named parameters.
CatalogItemDto testCatalogItem({
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
  final mediaKind = catalogMediaKindFromApiValue(kind);
  final defaults = _catalogFixtureDefaults[mediaKind];
  final resolvedPublisher = publisher ?? defaults?.publisher;
  final resolvedCreators = creators ?? defaults?.creators;
  final resolvedPublishing = publishing ?? defaults?.publishing;
  final mergedPayload = <String, dynamic>{
    if (itemNumber != null) 'item_number': itemNumber,
    if (editionTitle != null) 'edition_title': editionTitle,
    if (physicalFormat != null) 'physical_format': physicalFormat,
    if (physicalFormatLabel != null)
      'physical_format_label': physicalFormatLabel,
    if (resolvedPublisher != null) 'publisher': resolvedPublisher,
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
    if (resolvedCreators != null) 'creators': resolvedCreators,
    if (series != null) 'series': series.toJson(),
    if (video != null) 'video': video,
    if (music != null) 'music': music,
    if (game != null) 'game': game,
    if (resolvedPublishing != null) 'publishing': resolvedPublishing.toJson(),
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

extension ShelfCatalogFixture on CatalogItemDto {
  CatalogSearchCandidate get asShelfCatalogItem =>
      CatalogSearchCandidate.fromItem(this);
}

CatalogItemDto testCatalogItemFromJson(Map<String, dynamic> json) {
  return testCatalogItemWithKindMetadata(CatalogItemDto.fromJson(json));
}

CatalogItemDto testCatalogItemWithKindMetadata(CatalogItemDto item) {
  if (item.kindMetadata is! Map) return item;
  final payload = item.payload;
  final decoder = <CatalogMediaKind, Object? Function(Map<String, dynamic>)>{
    CatalogMediaKind.anime: AnimeMetadata.fromJson,
    CatalogMediaKind.boardgame: BoardGameMetadata.fromJson,
    CatalogMediaKind.book: BookCatalogMetadata.fromJson,
    CatalogMediaKind.comic: ComicMedia.fromJson,
    CatalogMediaKind.game: GameCatalogMetadata.fromJson,
    CatalogMediaKind.manga: MangaMetadata.fromJson,
    CatalogMediaKind.movie: MovieCatalogMetadata.fromJson,
    CatalogMediaKind.music: MusicCatalogMetadata.fromJson,
    CatalogMediaKind.tv: TvSeriesMetadata.fromJson,
  }[item.mediaKind];
  return decoder == null ? item : item.withKindMetadata(decoder(payload));
}

CatalogEntityRef testCatalogRef(
  String id, {
  String kind = 'unknown',
  CatalogEntityTypeId entityType = const CatalogEntityTypeId('work'),
}) {
  return CatalogEntityRef(
    kind: catalogMediaKindFromApiValue(kind),
    entityType: entityType,
    id: id,
  );
}

AddOwnedItemCommand typedAddOwnedItemCommand({
  required CatalogEntityRef catalogRef,
  required LibraryAddCommonDraft common,
  required JsonEncodable details,
  String? grade,
  OwnedItemCreatePayload? typedPayload,
  CatalogEntityRef? targetRef,
  OwnedItemTrackingDraft? tracking,
}) {
  if (typedPayload != null) {
    return AddOwnedItemCommand(
      catalogRef: catalogRef,
      typedPayload: typedPayload,
      targetRef: targetRef ?? catalogRefForLibrarySelection(catalogRef),
      tracking: tracking,
    );
  }
  final add = libraryKindRegistrationForKind(
    catalogRef.mediaKind,
  ).add;
  return add.buildCommandFromDetails(
    CatalogSearchCandidate.fromItem(
      testCatalogItem(
        id: catalogRef.id,
        kind: catalogRef.kind.apiValue,
      ),
    ),
    LibraryAddCommonDraft(
      condition: common.condition,
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
    draft: _addDraftWithGrade(catalogRef.mediaKind, grade),
    targetRef: targetRef ?? catalogRefForLibrarySelection(catalogRef),
    tracking: LibraryAddTrackingDraft(
      readStatus: mediaTrackingStatusToStorageValue(tracking?.status),
      rating: tracking?.rating,
      startedAt: tracking?.startedAt,
      finishedAt: tracking?.finishedAt,
      notes: tracking?.notes,
    ),
  );
}

LibraryAddKindDraft? _addDraftWithGrade(CatalogMediaKind kind, String? grade) {
  if (grade == null) return null;
  final factories = <CatalogMediaKind, LibraryAddKindDraft Function()>{
    CatalogMediaKind.anime: () => AnimeAddDraft(grade: grade),
    CatalogMediaKind.boardgame: () => BoardgameAddDraft(grade: grade),
    CatalogMediaKind.book: () => BookAddDraft(grade: grade),
    CatalogMediaKind.comic: () => ComicAddDraft(grade: grade),
    CatalogMediaKind.game: () => GameAddDraft(grade: grade),
    CatalogMediaKind.manga: () => MangaAddDraft(grade: grade),
    CatalogMediaKind.movie: () => MovieAddDraft(grade: grade),
    CatalogMediaKind.music: () => MusicAddDraft(grade: grade),
    CatalogMediaKind.tv: () => TvAddDraft(grade: grade),
  };
  return factories[kind]?.call();
}

/// Builds an [OwnedItem] with sensible defaults for testing.
TestOwnedItem testOwnedItem({
  String id = 'owned-1',
  String itemId = 'test-item-1',
  String kind = 'comic',
  CatalogEntityRef? catalogRef,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool? isDigital,
  CatalogEntityRef? targetRef,
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
  bool obiStripPresent = false,
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
        kind: catalogMediaKindFromApiValue(kind),
        entityType: const CatalogEntityTypeId('owned_copy'),
        id: itemId,
      );

  final detailBuilder = <CatalogMediaKind, JsonEncodable Function()>{
    CatalogMediaKind.comic: () => ComicOwnedDetails(
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
        ),
    CatalogMediaKind.manga: () => MangaOwnedDetails(
          signedBy: signedBy,
          gradingCompany: gradingCompany,
          graderNotes: graderNotes,
          obiStripPresent: obiStripPresent,
          printing: '1st Print',
          localizedEdition: 'English edition',
        ),
    CatalogMediaKind.movie: () => MovieOwnedDetails(
          features: features,
          hdrFormats: hdrFormats ?? const <String>[],
          boxSetId: boxSetId,
          boxSetName: boxSetName,
          region: region,
          packaging: packaging,
          distributor: distributor,
        ),
    CatalogMediaKind.tv: () => TvOwnedDetails(
          features: features,
          hdrFormats: hdrFormats ?? const <String>[],
          boxSetId: boxSetId,
          boxSetName: boxSetName,
          region: region,
          packaging: packaging,
          distributor: distributor,
        ),
    CatalogMediaKind.anime: () => AnimeOwnedDetails(
          features: features,
          hdrFormats: hdrFormats ?? const <String>[],
          boxSetId: boxSetId,
          boxSetName: boxSetName,
          region: region,
          packaging: packaging,
          distributor: distributor,
        ),
    CatalogMediaKind.game: () => GameOwnedDetails(
          completeness: gameCompleteness,
          hasBox: gameHasBox,
          hasManual: gameHasManual,
          priceChartingId: gamePriceChartingId,
          coreRegion: gameCoreRegion,
          valueIsLocked: gameValueIsLocked,
        ),
    CatalogMediaKind.boardgame: () => const BoardgameOwnedDetails(
          editionLanguage: 'English',
          editionRegion: 'US',
          componentCondition: 'Very Good',
          componentCompleteness: 'Complete',
        ),
    CatalogMediaKind.music: () => MusicOwnedDetails(
          storageDevice: storageDevice,
          storageSlot: storageSlot,
        ),
    CatalogMediaKind.book: () => BookOwnedDetails(
          signedBy: signedBy,
        ),
  }[resolvedCatalogRef.mediaKind];
  if (detailBuilder == null) {
    throw ArgumentError('Test owned item requires a registered kind: $kind');
  }
  final details = detailBuilder();

  return TestOwnedItem(
    id: id,
    catalogRef: resolvedCatalogRef,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.utc(2025, 1, 1),
    isDigital: isDigital,
    targetRef: targetRef ??
        ((editionId == null && variantId == null && bundleReleaseId == null)
            ? null
            : catalogRefForLibrarySelection(
                resolvedCatalogRef,
                editionId: editionId,
                variantId: variantId,
                bundleReleaseId: bundleReleaseId,
              )),
    details: details,
    condition: condition,
    collectionValue: grade,
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

OwnedItemSummary testOwnedItemSummary(TestOwnedItem item) {
  return OwnedItemSummary(
    ref: item.ref,
    title: item.itemId,
    catalogRef: item.catalogRef,
    targetRef: item.targetRef,
    isDigital: item.isDigital,
    collectionValue: item.collectionValue,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
    deletedAt: item.deletedAt,
    purchaseDate: item.purchaseDate,
    purchaseStore: item.purchaseStore,
    pricePaidCents: item.pricePaidCents,
    currency: item.currency,
    soldAt: item.soldAt,
    soldTo: item.soldTo,
    sellPriceCents: item.sellPriceCents,
    marketValueCents: item.marketValueCents,
    quantity: item.quantity,
    ownerLabel: item.ownerLabel,
    locationLabel: item.locationId,
    notes: item.personalNotes,
    hasNotes: item.personalNotes?.trim().isNotEmpty == true,
  );
}

OwnedItemSummary testOwnedSummary(TestOwnedItem item) =>
    testOwnedItemSummary(item);

ComicOwnedItem testComicOwnedItemFrom(TestOwnedItem item) =>
    ComicOwnedItem.fromJson(item.toJson());

BookOwnedItem testBookOwnedItemFrom(TestOwnedItem item) =>
    BookOwnedItem.fromJson(item.toJson());

MovieOwnedItem testMovieOwnedItemFrom(TestOwnedItem item) =>
    MovieOwnedItem.fromJson(item.toJson());

AnimeOwnedItem testAnimeOwnedItemFrom(TestOwnedItem item) =>
    AnimeOwnedItem.fromJson(item.toJson());

BoardGameOwnedItem testBoardGameOwnedItemFrom(TestOwnedItem item) =>
    BoardGameOwnedItem.fromJson(item.toJson());

GameOwnedItem testGameOwnedItemFrom(TestOwnedItem item) =>
    GameOwnedItem.fromJson(item.toJson());

MangaOwnedItem testMangaOwnedItemFrom(TestOwnedItem item) =>
    MangaOwnedItem.fromJson(item.toJson());

MusicOwnedItem testMusicOwnedItemFrom(TestOwnedItem item) =>
    MusicOwnedItem.fromJson(item.toJson());

TvOwnedItem testTvOwnedItemFrom(TestOwnedItem item) =>
    TvOwnedItem.fromJson(item.toJson());

LibraryOwnedItemDispatch testOwnedItemDispatchFrom(TestOwnedItem item) {
  final factories = <CatalogMediaKind, LibraryOwnedItemDispatch Function()>{
    CatalogMediaKind.anime: () => AnimeOwnedItemDispatch(
          ref: item.ref,
          value: testAnimeOwnedItemFrom(item),
        ),
    CatalogMediaKind.boardgame: () => BoardGameOwnedItemDispatch(
          ref: item.ref,
          value: testBoardGameOwnedItemFrom(item),
        ),
    CatalogMediaKind.book: () => BookOwnedItemDispatch(
          ref: item.ref,
          value: testBookOwnedItemFrom(item),
        ),
    CatalogMediaKind.comic: () => ComicOwnedItemDispatch(
          ref: item.ref,
          value: testComicOwnedItemFrom(item),
        ),
    CatalogMediaKind.game: () => GameOwnedItemDispatch(
          ref: item.ref,
          value: testGameOwnedItemFrom(item),
        ),
    CatalogMediaKind.manga: () => MangaOwnedItemDispatch(
          ref: item.ref,
          value: testMangaOwnedItemFrom(item),
        ),
    CatalogMediaKind.movie: () => MovieOwnedItemDispatch(
          ref: item.ref,
          value: testMovieOwnedItemFrom(item),
        ),
    CatalogMediaKind.music: () => MusicOwnedItemDispatch(
          ref: item.ref,
          value: testMusicOwnedItemFrom(item),
        ),
    CatalogMediaKind.tv: () => TvOwnedItemDispatch(
          ref: item.ref,
          value: testTvOwnedItemFrom(item),
        ),
  };
  final factory = factories[item.catalogRef.mediaKind];
  if (factory == null) {
    throw ArgumentError.value(
      item.catalogRef.mediaKind,
      'item',
      'Test Owned fixture requires an active kind',
    );
  }
  return factory();
}

OwnedItemRef _testOwnedItemRef(CatalogEntityRef catalogRef, String id) =>
    OwnedItemRef(
      kind: catalogRef.mediaKind,
      id: OwnedItemId(id),
    );

ComicOwnedItemDispatch testComicOwnedItemDispatchFrom(ComicOwnedItem item) =>
    ComicOwnedItemDispatch(
      ref: _testOwnedItemRef(item.catalogRef, item.id.value),
      value: item,
    );

GameOwnedItemDispatch testGameOwnedItemDispatchFrom(GameOwnedItem item) =>
    GameOwnedItemDispatch(
      ref: _testOwnedItemRef(item.catalogRef, item.id.value),
      value: item,
    );

MangaOwnedItemDispatch testMangaOwnedItemDispatchFrom(MangaOwnedItem item) =>
    MangaOwnedItemDispatch(
      ref: _testOwnedItemRef(item.catalogRef, item.id.value),
      value: item,
    );

MovieOwnedItemDispatch testMovieOwnedItemDispatchFrom(MovieOwnedItem item) =>
    MovieOwnedItemDispatch(
      ref: _testOwnedItemRef(item.catalogRef, item.id.value),
      value: item,
    );

/// Builds a [LibraryWorkspaceSource] with sensible defaults for testing.
///
/// If [catalogTransport] is omitted, a default one is created from [itemId] and
/// [kind].
LibraryWorkspaceSource testLibraryWorkspaceSource({
  String itemId = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  CatalogItemDto? catalogTransport,
  TestOwnedItem? ownedItem,
  String? locationPath,
}) {
  final resolvedCatalogItem = catalogTransport ??
      testCatalogItem(
        id: itemId,
        kind: kind,
        title: title,
      );
  final ownedItemDispatch =
      ownedItem == null ? null : testOwnedItemDispatchFrom(ownedItem);
  return LibraryWorkspaceSource(
    itemId: itemId,
    catalogSummary: CatalogSearchCandidate.fromItem(
      testCatalogItemWithKindMetadata(resolvedCatalogItem),
    ).displaySummary,
    catalogTransport: CatalogSearchCandidate.fromItem(
      testCatalogItemWithKindMetadata(resolvedCatalogItem),
    ),
    ownedSummary: ownedItem == null ? null : testOwnedItemSummary(ownedItem),
    ownedItemDispatch: ownedItemDispatch,
    locationPath: locationPath,
  );
}

LibraryProjectionView testProjectionItem({
  String? id,
  String itemId = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  String? barcode,
  CatalogItemDto? catalogItem,
  TestOwnedItem? ownedItem,
  String? locationPath,
}) {
  final resolvedId = id ?? itemId;
  final shelf = testLibraryWorkspaceSource(
    itemId: resolvedId,
    kind: kind,
    title: title,
    catalogTransport: catalogItem ??
        testCatalogItem(
            id: resolvedId, kind: kind, title: title, barcode: barcode),
    ownedItem: ownedItem,
    locationPath: locationPath,
  );
  final node = LibraryTitleNodeRef(titleItemId: resolvedId);
  final mediaKind = catalogMediaKindFromApiValue(kind);
  final dto = libraryKindWorkspaceForKind(mediaKind).projector.projectTitle(
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
