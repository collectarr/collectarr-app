import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_library_entry.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import '../fixtures/entry_details_codec_fixtures.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import '../fixtures/test_library_entry_fixture.dart';

import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';

export '../fixtures/test_library_entry_fixture.dart';

TestLibraryEntry testLibraryEntry({
  String id = 'entry-1',
  String itemId = 'test-item-1',
  required String kind,
  String catalogTitle = 'Test Item',
  JsonEncodable? details,
  CatalogItemRef? catalogRef,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool? isDigital,
  String? condition,
  String? grade,
  DateTime? purchaseDate,
  int? pricePaidCents,
  String? currency,
  String? personalNotes,
  int? indexNumber,
  String? tags,
  DateTime? deletedAt,
  DateTime? soldAt,
  int? sellPriceCents,
  String? soldTo,
  String? ownerUserId,
  String? ownerLabel,
  String? locationId,
  String? purchaseStore,
  String? collectionStatus,
  int? marketValueCents,
}) {
  final resolvedCatalogRef = catalogRef ??
      CatalogItemRef(
        kind: catalogMediaKindFromApiValue(kind),
        id: itemId,
      );

  if (resolvedCatalogRef.kind != catalogMediaKindFromApiValue(kind)) {
    throw ArgumentError('Entry fixture kind must match catalog provenance.');
  }
  final detailsFixture = entryDetailsFixtureForTest(resolvedCatalogRef.kind);
  final resolvedDetails = details ?? detailsFixture.defaultDetails();
  detailsFixture.validate(resolvedDetails);

  return TestLibraryEntry(
    id: id,
    catalogRef: resolvedCatalogRef,
    catalogTitle: catalogTitle,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.utc(2025, 1, 1),
    isDigital: isDigital,
    details: resolvedDetails,
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

GameHardwareLibraryEntry testGameHardwareLibraryEntryFrom(
        TestLibraryEntry item) =>
    GameHardwareLibraryEntry.fromJson(item.toJson());

GameToyLibraryEntry testGameToyLibraryEntryFrom(TestLibraryEntry item) =>
    GameToyLibraryEntry.fromJson(item.toJson());

MusicLibraryEntry testMusicLibraryEntryFrom(TestLibraryEntry item) =>
    MusicLibraryEntry.fromJson({
      ...item.toJson(),
      'catalog_data': MusicAlbum(title: item.catalogTitle).toJson(),
    });

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
    CatalogMediaKind.gameHardware => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.gameHardware,
        ref: item.ref,
        value: testGameHardwareLibraryEntryFrom(item),
      ),
    CatalogMediaKind.gameToy => OpaqueLibraryEntryDispatch(
        kind: CatalogMediaKind.gameToy,
        ref: item.ref,
        value: testGameToyLibraryEntryFrom(item),
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
