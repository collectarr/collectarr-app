import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import '../fixtures/test_library_entry_fixture.dart';

import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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

export '../fixtures/test_library_entry_fixture.dart';

TestLibraryEntry testLibraryEntry({
  String id = 'entry-1',
  String itemId = 'test-item-1',
  String kind = 'comic',
  String catalogTitle = 'Test Item',
  String? catalogIssueNumber,
  CatalogItemRef? catalogRef,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool? isDigital,
  CatalogItemRef? targetRef,
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
      CatalogItemRef(
        kind: catalogMediaKindFromApiValue(kind),
        id: itemId,
      );

  final details = switch (resolvedCatalogRef.kind) {
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
          MusicEntryDiscDetails(
            discId: 'disc-1',
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

  final resolvedTargetRef = targetRef;

  return TestLibraryEntry(
    id: id,
    catalogRef: resolvedCatalogRef,
    catalogTitle: catalogTitle,
    catalogIssueNumber: catalogIssueNumber,
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

LibraryEntrySummary testLibraryEntrySummary(TestLibraryEntry item) {
  return LibraryEntrySummary(
    ref: item.ref,
    sourceCatalogRef: item.catalogRef,
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
    locationId: item.locationId,
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

BoardGameLibraryEntry testBoardGameLibraryEntryFrom(TestLibraryEntry item) =>
    BoardGameLibraryEntry.fromJson(item.toJson());

GameLibraryEntry testGameLibraryEntryFrom(TestLibraryEntry item) =>
    GameLibraryEntry.fromJson(item.toJson());

MangaLibraryEntry testMangaLibraryEntryFrom(TestLibraryEntry item) =>
    MangaLibraryEntry.fromJson(item.toJson());

MusicLibraryEntry testMusicLibraryEntryFrom(TestLibraryEntry item) =>
    MusicLibraryEntry.fromJson({
      ...item.toJson(),
      'catalog_data': MusicAlbum(title: item.catalogTitle).toJson(),
    });

TvLibraryEntry testTvLibraryEntryFrom(TestLibraryEntry item) =>
    TvLibraryEntry.fromJson(item.toJson());

LibraryEntryDispatch testLibraryEntryDispatchFrom(TestLibraryEntry item) {
  return switch (item.catalogRef.kind) {
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
        item.catalogRef.kind,
        'item',
        'Test Entry fixture requires an active kind',
      ),
  };
}

LibraryEntryDispatch testComicLibraryEntryDispatchFrom(
        ComicLibraryEntry item) =>
    OpaqueLibraryEntryDispatch(
      kind: CatalogMediaKind.comic,
      ref: LibraryEntryRef(kind: CatalogMediaKind.comic, id: item.id),
      value: item,
    );

LibraryEntryDispatch testGameLibraryEntryDispatchFrom(GameLibraryEntry item) =>
    OpaqueLibraryEntryDispatch(
      kind: CatalogMediaKind.game,
      ref: LibraryEntryRef(kind: CatalogMediaKind.game, id: item.id),
      value: item,
    );

LibraryEntryDispatch testMangaLibraryEntryDispatchFrom(
        MangaLibraryEntry item) =>
    OpaqueLibraryEntryDispatch(
      kind: CatalogMediaKind.manga,
      ref: LibraryEntryRef(kind: CatalogMediaKind.manga, id: item.id),
      value: item,
    );

LibraryEntryDispatch testMovieLibraryEntryDispatchFrom(
        MovieLibraryEntry item) =>
    OpaqueLibraryEntryDispatch(
      kind: CatalogMediaKind.movie,
      ref: LibraryEntryRef(kind: CatalogMediaKind.movie, id: item.id),
      value: item,
    );

WishlistItem testWishlistItem({
  String id = 'wish-1',
  required String itemId,
  String kind = 'comic',
  DateTime? updatedAt,
}) {
  final dt = updatedAt ?? DateTime.utc(2026, 1, 1);
  return WishlistItem(
    id: id,
    catalogRef: CatalogItemRef(
      kind: catalogMediaKindFromApiValue(kind),
      id: itemId,
    ),
    createdAt: dt,
    updatedAt: dt,
  );
}
