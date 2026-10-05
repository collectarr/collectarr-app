import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/test/helpers/test_library_entry_fixture.dart';

export 'test_library_entry_fixture.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_workspace_data_dispatch.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';
import 'package:collectarr_app/features/library/kinds/anime/entries/anime_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/entries/boardgame_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/entries/tv_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/manga/entries/manga_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/add/movie_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/tv/add/tv_add_draft.dart';

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
  final kindData = <String, dynamic>{
    'title': title,
    if (displayTitle != null) 'display_title': displayTitle,
    if (localizedTitle != null) 'localized_title': localizedTitle,
    if (originalTitle != null) 'original_title': originalTitle,
    if (titleExtension != null) 'title_extension': titleExtension,
    if (searchAliases != null) 'search_aliases': searchAliases,
    if (synopsis != null) 'synopsis': synopsis,
    if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
    if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
    if (coverImageData != null) 'cover_image_data': coverImageData,
    if (sortKey != null) 'sort_key': sortKey,
    if (releaseDate != null) 'release_date': releaseDate.toIso8601String(),
    if (releaseYear != null) 'release_year': releaseYear,
    if (editions?.isNotEmpty ?? false)
      'editions': editions!.map((edition) => edition.toJson()).toList(),
    if (trailerUrls?.isNotEmpty ?? false)
      'trailer_urls': trailerUrls!.map((link) => link.toJson()).toList(),
    ...mergedPayload,
  };
  return CatalogItemDto.raw(
    id: id,
    mediaKind: catalogMediaKindFromValue(kind),
    kindData: kindData,
  );
}

extension ShelfCatalogFixture on CatalogItemDto {
  CatalogItemDto get asShelfCatalogItem => this;

  CatalogSearchCandidate get asSearchCandidate =>
      CatalogSearchCandidate.fromItem(this);

  CatalogDisplaySummary get asShelfCatalogSummary =>
      CatalogSearchCandidate.fromItem(this).summary;

  LibraryWorkspaceKindData get asShelfCatalogData =>
      workspaceCatalogDataFromTransport(CatalogImportTransport.fromItem(this));
}

LibraryWorkspaceKindData testWorkspaceCatalogData(CatalogItemDto item) =>
    workspaceCatalogDataFromTransport(
      CatalogImportTransport.fromItem(item),
    );

CatalogItemDto testCatalogItemFromJson(Map<String, dynamic> json) {
  return testCatalogItemWithKindMetadata(CatalogItemDto.fromJson(json));
}

CatalogItemDto testCatalogItemWithKindMetadata(CatalogItemDto item) {
  return item;
}

CatalogEntityRef testCatalogRef(
  String id, {
  String kind = 'unknown',
  CatalogEntityTypeId entityType = CatalogEntityTypeId.catalogItem,
}) {
  return CatalogEntityRef(
    kind: catalogMediaKindFromApiValue(kind),
    entityType: entityType,
    id: id,
  );
}

AddLibraryEntryCommand typedAddLibraryEntryCommand({
  required CatalogEntityRef catalogRef,
  required LibraryAddCommonDraft common,
  required JsonEncodable details,
  String? grade,
  LibraryEntryCreatePayload? typedPayload,
  LibraryEntryTrackingDraft? tracking,
}) {
  if (typedPayload != null) {
    return AddLibraryEntryCommand(
      catalogRef: catalogRef,
      typedPayload: typedPayload,
      tracking: tracking,
    );
  }
  final add = libraryAddForKind(catalogRef.mediaKind);
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
      tags: common.tags,
      locationId: common.locationId,
      purchaseStore: common.purchaseStore,
      collectionStatus: common.collectionStatus,
      isDigital: common.isDigital,
    ),
    details,
    draft: _addDraftWithGrade(catalogRef.mediaKind, grade),
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
  return switch (kind) {
    CatalogMediaKind.anime => AnimeAddDraft(grade: grade),
    CatalogMediaKind.boardgame => BoardgameAddDraft(grade: grade),
    CatalogMediaKind.book => BookAddDraft(grade: grade),
    CatalogMediaKind.comic => ComicAddDraft(grade: grade),
    CatalogMediaKind.game => GameAddDraft(grade: grade),
    CatalogMediaKind.manga => MangaAddDraft(grade: grade),
    CatalogMediaKind.movie => MovieAddDraft(grade: grade),
    CatalogMediaKind.music => MusicAddDraft(grade: grade),
    CatalogMediaKind.tv => TvAddDraft(grade: grade),
    CatalogMediaKind.unknown => null,
  };
}

TestLibraryEntry testLibraryEntry({
  String id = 'entry-1',
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
        entityType: CatalogEntityTypeId.catalogItem,
        id: itemId,
      );

  final details = switch (resolvedCatalogRef.mediaKind) {
    CatalogMediaKind.comic => ComicEntryDetails(
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
    CatalogMediaKind.manga => MangaEntryDetails(
        signedBy: signedBy,
        gradingCompany: gradingCompany,
        graderNotes: graderNotes,
        obiStripPresent: obiStripPresent,
        printing: '1st Print',
        localizedEdition: 'English edition',
      ),
    CatalogMediaKind.movie => MovieEntryDetails(
        features: features,
        hdrFormats: hdrFormats ?? const <String>[],
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      ),
    CatalogMediaKind.tv => TvEntryDetails(
        features: features,
        hdrFormats: hdrFormats ?? const <String>[],
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      ),
    CatalogMediaKind.anime => AnimeEntryDetails(
        features: features,
        hdrFormats: hdrFormats ?? const <String>[],
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      ),
    CatalogMediaKind.game => GameEntryDetails(
        completeness: gameCompleteness,
        hasBox: gameHasBox,
        hasManual: gameHasManual,
        priceChartingId: gamePriceChartingId,
        coreRegion: gameCoreRegion,
        valueIsLocked: gameValueIsLocked,
      ),
    CatalogMediaKind.boardgame => const BoardgameEntryDetails(
        editionLanguage: 'English',
        editionRegion: 'US',
        componentCondition: 'Very Good',
        componentCompleteness: 'Complete',
      ),
    CatalogMediaKind.music => MusicEntryDetails(
        media: [
          MusicEntryMediumDetails(
            mediumIndex: 1,
            storageDevice: storageDevice,
            storageSlot: storageSlot,
          ),
        ],
      ),
    CatalogMediaKind.book => BookEntryDetails(
        signedBy: signedBy,
      ),
    CatalogMediaKind.unknown => throw ArgumentError(
        'Test collection item requires a registered kind: $kind'),
  };

  final resolvedTargetRef = targetRef ??
      (resolvedCatalogRef.mediaKind == CatalogMediaKind.music &&
              editionId == null &&
              variantId == null &&
              bundleReleaseId == null
          ? CatalogEntityRef(
              kind: CatalogMediaKind.music,
              entityType: const CatalogEntityTypeId('release'),
              id: '${resolvedCatalogRef.rootScope.id}:release',
              rootId: resolvedCatalogRef.rootScope.id,
            )
          : ((editionId == null && variantId == null && bundleReleaseId == null)
              ? null
              : _testTargetRef(
                  resolvedCatalogRef,
                  editionId: editionId,
                  variantId: variantId,
                  bundleReleaseId: bundleReleaseId,
                )));

  return TestLibraryEntry(
    id: id,
    catalogRef: resolvedCatalogRef,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.utc(2025, 1, 1),
    isDigital: isDigital,
    targetRef: resolvedTargetRef,
    details: details,
    condition: condition,
    collectionValue: grade,
    purchaseDate: purchaseDate,
    pricePaidCents: pricePaidCents,
    currency: currency,
    personalNotes: personalNotes,
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

CatalogEntityRef _testTargetRef(
  CatalogEntityRef root, {
  String? editionId,
  String? variantId,
  String? bundleReleaseId,
}) {
  final referenceType = bundleReleaseId != null
      ? LibraryAddReferenceType.bundleRelease
      : editionId != null || variantId != null
          ? LibraryAddReferenceType.edition
          : LibraryAddReferenceType.media;
  return libraryCatalogTargetForKind(root.kind).resolve(
    root,
    LibraryCatalogTargetSelection(
      referenceType: referenceType,
      firstId: editionId,
      secondId: variantId,
      groupId: bundleReleaseId,
    ),
  );
}

LibraryEntrySummary testLibraryEntrySummary(TestLibraryEntry item) {
  return LibraryEntrySummary(
    ref: item.ref,
    catalogRef: item.catalogRef,
    isDigital: item.isDigital,
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
    ownerLabel: item.ownerLabel,
    locationLabel: item.locationId,
    notes: item.personalNotes,
    hasNotes: item.personalNotes?.trim().isNotEmpty == true,
  );
}

ComicLibraryEntry testComicLibraryEntryFrom(TestLibraryEntry item) =>
    ComicLibraryEntry.fromJson(item.toJson());

BookLibraryEntry testBookLibraryEntryFrom(TestLibraryEntry item) =>
    BookLibraryEntry.fromJson(item.toJson());

MovieLibraryEntry testMovieLibraryEntryFrom(TestLibraryEntry item) =>
    MovieLibraryEntry.fromJson(item.toJson());

AnimeLibraryEntry testAnimeLibraryEntryFrom(TestLibraryEntry item) =>
    AnimeLibraryEntry.fromJson(item.toJson());

BoardGameLibraryEntry testBoardGameLibraryEntryFrom(
        TestLibraryEntry item) =>
    BoardGameLibraryEntry.fromJson(item.toJson());

GameLibraryEntry testGameLibraryEntryFrom(TestLibraryEntry item) =>
    GameLibraryEntry.fromJson(item.toJson());

MangaLibraryEntry testMangaLibraryEntryFrom(TestLibraryEntry item) =>
    MangaLibraryEntry.fromJson(item.toJson());

MusicLibraryEntry testMusicLibraryEntryFrom(TestLibraryEntry item) =>
    MusicLibraryEntry.fromJson(item.toJson());

TvLibraryEntry testTvLibraryEntryFrom(TestLibraryEntry item) =>
    TvLibraryEntry.fromJson(item.toJson());

LibraryEntryDispatch testLibraryEntryDispatchFrom(
    TestLibraryEntry item) {
  return switch (item.catalogRef.mediaKind) {
    CatalogMediaKind.anime => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.anime,
        ref: item.ref,
        value: testAnimeLibraryEntryFrom(item),
      ),
    CatalogMediaKind.boardgame => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.boardgame,
        ref: item.ref,
        value: testBoardGameLibraryEntryFrom(item),
      ),
    CatalogMediaKind.book => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.book,
        ref: item.ref,
        value: testBookLibraryEntryFrom(item),
      ),
    CatalogMediaKind.comic => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.comic,
        ref: item.ref,
        value: testComicLibraryEntryFrom(item),
      ),
    CatalogMediaKind.game => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.game,
        ref: item.ref,
        value: testGameLibraryEntryFrom(item),
      ),
    CatalogMediaKind.manga => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.manga,
        ref: item.ref,
        value: testMangaLibraryEntryFrom(item),
      ),
    CatalogMediaKind.movie => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.movie,
        ref: item.ref,
        value: testMovieLibraryEntryFrom(item),
      ),
    CatalogMediaKind.music => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.music,
        ref: item.ref,
        value: testMusicLibraryEntryFrom(item),
      ),
    CatalogMediaKind.tv => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.tv,
        ref: item.ref,
        value: testTvLibraryEntryFrom(item),
      ),
    CatalogMediaKind.unknown => throw ArgumentError.value(
        item.catalogRef.mediaKind,
        'item',
        'Test Entry fixture requires an active kind',
      ),
  };
}

LibraryEntryRef _testLibraryEntryRef(
        CatalogEntityRef catalogRef, String id) =>
    LibraryEntryRef(
      kind: catalogRef.mediaKind,
      id: LibraryEntryId(id),
    );

LibraryEntryDispatch testComicLibraryEntryDispatchFrom(
        ComicLibraryEntry item) =>
    OpaqueLibraryEntryDispatch(
      kind: CatalogMediaKind.comic,
      ref: _testLibraryEntryRef(item.catalogRef, item.id.value),
      value: item,
    );

LibraryEntryDispatch testGameLibraryEntryDispatchFrom(
        GameLibraryEntry item) =>
    OpaqueLibraryEntryDispatch(
      kind: CatalogMediaKind.game,
      ref: _testLibraryEntryRef(item.catalogRef, item.id.value),
      value: item,
    );

LibraryEntryDispatch testMangaLibraryEntryDispatchFrom(
        MangaLibraryEntry item) =>
    OpaqueLibraryEntryDispatch(
      kind: CatalogMediaKind.manga,
      ref: _testLibraryEntryRef(item.catalogRef, item.id.value),
      value: item,
    );

LibraryEntryDispatch testMovieLibraryEntryDispatchFrom(
        MovieLibraryEntry item) =>
    OpaqueLibraryEntryDispatch(
      kind: CatalogMediaKind.movie,
      ref: _testLibraryEntryRef(item.catalogRef, item.id.value),
      value: item,
    );

LibraryWorkspaceContext testLibraryWorkspaceContext({
  String itemId = 'test-item-1',
  String kind = 'comic',
  String title = 'Test Item',
  CatalogItemDto? catalogItem,
  LibraryWorkspaceKindData? catalogData,
  TestLibraryEntry? libraryEntry,
  WishlistItem? wishlistItem,
  String? locationPath,
}) {
  final resolvedCatalogItem = catalogItem ??
      testCatalogItem(
        id: itemId,
        kind: kind,
        title: title,
      );
  final libraryEntryDispatch = libraryEntry == null
      ? null
      : testLibraryEntryDispatchFrom(libraryEntry);
  return LibraryWorkspaceContext(
    itemId: itemId,
    catalogSummary: CatalogSearchCandidate.fromItem(
      testCatalogItemWithKindMetadata(resolvedCatalogItem),
    ).summary,
    catalogData: catalogData ??
        workspaceCatalogDataFromTransport(
          CatalogImportTransport.fromItem(
            testCatalogItemWithKindMetadata(resolvedCatalogItem),
          ),
        ),
    libraryEntrySummary: libraryEntry == null
        ? null
        : testLibraryEntrySummary(libraryEntry),
    libraryEntryDispatch: libraryEntryDispatch,
    wishlistItem: wishlistItem,
    locationPath: locationPath,
  );
}

TrackingSummary trackingSummaryFromRecord(TrackingStorageRecord record) {
  return TrackingSummary(
    id: record.id,
    catalogRef: record.catalogRef,
    libraryEntryRef: record.libraryEntryRef,
    sourceType: record.sourceType,
    status: record.status ?? MediaTrackingStatus.none,
    rating: record.rating,
    startedAt: record.startedAt,
    completedAt: record.finishedAt,
    notes: record.notes,
    updatedAt: record.updatedAt,
    deletedAt: record.deletedAt,
    progress: record.progress,
  );
}
