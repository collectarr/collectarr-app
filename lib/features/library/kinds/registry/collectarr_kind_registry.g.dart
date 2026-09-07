// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration_adapter.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/page.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/page.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/page.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/page.dart';
import 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/game/game_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/game/page.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/page.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/page.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/page.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/page.dart';
import 'package:collectarr_app/features/library/kinds/anime/calendar/anime_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/activity/anime_activity_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/admin/anime_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/barcode/anime_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/anime/integrations/collection_csv/anime_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/calendar/boardgame_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/admin/boardgame_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/barcode/boardgame_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/collection_csv/boardgame_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/provider/boardgame_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/calendar/book_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/admin/book_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/barcode/book_isbn_resolver.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/collection_csv/book_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/provider/book_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/calendar/comic_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/admin/comic_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/barcode/comic_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/collection_csv/comic_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/calendar/game_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/admin/game_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/barcode/game_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/collection_csv/game_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/calendar/manga_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/admin/manga_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/barcode/manga_identifier_resolver.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_csv/manga_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_shelf/manga_shelf_extension_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/calendar/movie_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/admin/movie_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/barcode/movie_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/movie/integrations/collection_csv/movie_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/calendar/music_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/admin/music_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/barcode/music_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/collection_csv/music_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/calendar/tv_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/activity/tv_activity_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/admin/tv_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/barcode/tv_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/collection_csv/tv_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';
import 'package:collectarr_app/features/library/config/library_activity_contributor.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/config/library_barcode_resolver.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/config/library_shelf_extension_contributor.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';

final List<LibraryKindModule> collectarrKindModules = [
  animeKindModule,
  boardGameKindModule,
  bookKindModule,
  comicKindModule,
  gameKindModule,
  mangaKindModule,
  movieKindModule,
  musicKindModule,
  tvKindModule,
];

final collectarrKindCalendarContributors = <CatalogMediaKind, LibraryCalendarContributor>{
  CatalogMediaKind.anime: const AnimeCalendarContributor(),
  CatalogMediaKind.boardgame: const BoardGameCalendarContributor(),
  CatalogMediaKind.book: const BookCalendarContributor(),
  CatalogMediaKind.comic: const ComicCalendarContributor(),
  CatalogMediaKind.game: const GameCalendarContributor(),
  CatalogMediaKind.manga: const MangaCalendarContributor(),
  CatalogMediaKind.movie: const MovieCalendarContributor(),
  CatalogMediaKind.music: const MusicCalendarContributor(),
  CatalogMediaKind.tv: const TvCalendarContributor(),
};

final collectarrKindActivityContributors = <CatalogMediaKind, LibraryActivityContributor>{
  CatalogMediaKind.anime: const AnimeActivityContributor(),
  CatalogMediaKind.tv: const TvActivityContributor(),
};

final collectarrKindAdminContributors = <CatalogMediaKind, LibraryAdminContributor>{
  CatalogMediaKind.anime: const AnimeAdminContributor(),
  CatalogMediaKind.boardgame: const BoardGameAdminContributor(),
  CatalogMediaKind.book: const BookAdminContributor(),
  CatalogMediaKind.comic: const ComicAdminContributor(),
  CatalogMediaKind.game: const GameAdminContributor(),
  CatalogMediaKind.manga: const MangaAdminContributor(),
  CatalogMediaKind.movie: const MovieAdminContributor(),
  CatalogMediaKind.music: const MusicAdminContributor(),
  CatalogMediaKind.tv: const TvAdminContributor(),
};

final collectarrKindBarcodeResolvers = <CatalogMediaKind, LibraryBarcodeResolver>{
  CatalogMediaKind.anime: const AnimeBarcodeResolver(),
  CatalogMediaKind.boardgame: const BoardGameBarcodeResolver(),
  CatalogMediaKind.book: const BookIsbnResolver(),
  CatalogMediaKind.comic: const ComicBarcodeResolver(),
  CatalogMediaKind.game: const GameBarcodeResolver(),
  CatalogMediaKind.manga: const MangaIdentifierResolver(),
  CatalogMediaKind.movie: const MovieBarcodeResolver(),
  CatalogMediaKind.music: const MusicBarcodeResolver(),
  CatalogMediaKind.tv: const TvBarcodeResolver(),
};

final collectarrKindCollectionCsvProjections = <CatalogMediaKind, LibraryCollectionCsvProjection>{
  CatalogMediaKind.anime: const AnimeCollectionCsvProjection(),
  CatalogMediaKind.boardgame: const BoardGameCollectionCsvProjection(),
  CatalogMediaKind.book: const BookCollectionCsvProjection(),
  CatalogMediaKind.comic: const ComicCollectionCsvProjection(),
  CatalogMediaKind.game: const GameCollectionCsvProjection(),
  CatalogMediaKind.manga: const MangaCollectionCsvProjection(),
  CatalogMediaKind.movie: const MovieCollectionCsvProjection(),
  CatalogMediaKind.music: const MusicCollectionCsvProjection(),
  CatalogMediaKind.tv: const TvCollectionCsvProjection(),
};

final collectarrKindShelfExtensions = <CatalogMediaKind, LibraryShelfExtensionContributor>{
  CatalogMediaKind.manga: const MangaShelfExtensionContributor(),
};

final collectarrKindProviderMappers = <CatalogMediaKind, LibraryKindProviderMapper>{
  CatalogMediaKind.anime: const AnimeLibraryKindProviderMapper(),
  CatalogMediaKind.boardgame: const BoardGameLibraryKindProviderMapper(),
  CatalogMediaKind.book: const BookLibraryKindProviderMapper(),
  CatalogMediaKind.comic: const ComicLibraryKindProviderMapper(),
  CatalogMediaKind.game: const GameLibraryKindProviderMapper(),
  CatalogMediaKind.manga: const MangaLibraryKindProviderMapper(),
  CatalogMediaKind.movie: const MovieLibraryKindProviderMapper(),
  CatalogMediaKind.music: const MusicLibraryKindProviderMapper(),
  CatalogMediaKind.tv: const TvLibraryKindProviderMapper(),
};

final collectarrKindOwnedDetailsCodecs = <CatalogMediaKind, OwnedDetailsPersistenceCodec>{
  CatalogMediaKind.anime: const AnimeOwnedDetailsCodec(),
  CatalogMediaKind.boardgame: const BoardgameOwnedDetailsCodec(),
  CatalogMediaKind.book: const BookOwnedDetailsCodec(),
  CatalogMediaKind.comic: const ComicOwnedDetailsCodec(),
  CatalogMediaKind.game: const GameOwnedDetailsCodec(),
  CatalogMediaKind.manga: const MangaOwnedDetailsCodec(),
  CatalogMediaKind.movie: const MovieOwnedDetailsCodec(),
  CatalogMediaKind.music: const MusicOwnedDetailsCodec(),
  CatalogMediaKind.tv: const TvOwnedDetailsCodec(),
};

final collectarrKindFacetModules = <CatalogMediaKind, LibraryFacetModule>{
  CatalogMediaKind.anime: animeLibraryFacetModule,
  CatalogMediaKind.boardgame: boardGameLibraryFacetModule,
  CatalogMediaKind.book: bookLibraryFacetModule,
  CatalogMediaKind.comic: comicLibraryFacetModule,
  CatalogMediaKind.game: gameLibraryFacetModule,
  CatalogMediaKind.manga: mangaLibraryFacetModule,
  CatalogMediaKind.movie: movieLibraryFacetModule,
  CatalogMediaKind.music: musicLibraryFacetModule,
  CatalogMediaKind.tv: tvLibraryFacetModule,
};
final collectarrKindMetadataDecoders = <CatalogMediaKind, Object? Function(Map<String, dynamic>)>{
  CatalogMediaKind.anime: AnimeMetadata.fromJson,
  CatalogMediaKind.boardgame: BoardGameMetadata.fromJson,
  CatalogMediaKind.book: BookCatalogMetadata.fromJson,
  CatalogMediaKind.comic: ComicMedia.fromJson,
  CatalogMediaKind.game: GameCatalogMetadata.fromJson,
  CatalogMediaKind.manga: MangaMetadata.fromJson,
  CatalogMediaKind.movie: MovieCatalogMetadata.fromJson,
  CatalogMediaKind.music: MusicCatalogMetadata.fromJson,
  CatalogMediaKind.tv: TvSeriesMetadata.fromJson,
};

LibraryKindModule? lookupLibraryKind(CatalogMediaKind kind) {
  for (final module in collectarrKindModules) {
    if (module.kind == kind) return module;
  }
  return null;
}

LibraryKindModule libraryKindFor(CatalogMediaKind kind) {
  final module = lookupLibraryKind(kind);
  if (module != null) return module;
  throw ArgumentError('No LibraryKindModule registered for kind "$kind"');
}

final List<LibraryKindRegistration> collectarrKindRegistrations = [
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.anime,
    module: animeKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) => AnimeLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.boardgame,
    module: boardGameKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) => BoardGameLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.book,
    module: bookKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) => BookLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.comic,
    module: comicKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) => ComicLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.game,
    module: gameKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) => GameLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.manga,
    module: mangaKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) => MangaLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.movie,
    module: movieKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) => MovieLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.music,
    module: musicKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) => MusicLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
  LibraryKindRegistrationAdapter(
    kind: CatalogMediaKind.tv,
    module: tvKindModule,
    pageBuilder: ({
      required LibraryKindModule type,
      required Widget topBar,
      required Color accent,
      required Uri routeUri,
      LibraryLayoutSnapshot? switchLayoutSnapshot,
    }) => TvLibraryPage(
      type: type,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    ),
  ),
];

LibraryKindRegistration libraryKindRegistrationForKind(CatalogMediaKind kind) {
  for (final registration in collectarrKindRegistrations) {
    if (registration.kind == kind) return registration;
  }
  throw ArgumentError(
    'No LibraryKindRegistration registered for kind "$kind"',
  );
}
