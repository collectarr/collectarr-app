// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/edit/library_edit_launcher.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_layout_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:collectarr_app/features/library/kinds/anime/integrations/catalog/anime_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_custom_episode_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/calendar/boardgame_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/admin/boardgame_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/barcode/boardgame_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/collection_csv/boardgame_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/catalog/boardgame_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/provider/boardgame_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/calendar/book_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/admin/book_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/barcode/book_isbn_resolver.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/collection_csv/book_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/catalog/book_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/provider/book_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/calendar/comic_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/admin/comic_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/barcode/comic_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/collection_csv/comic_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/comic_info/comic_info_export.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/catalog/comic_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/comic/detail/comic_route_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/calendar/game_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/admin/game_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/barcode/game_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/collection_csv/game_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/catalog/game_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/calendar/manga_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/admin/manga_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/barcode/manga_identifier_resolver.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_csv/manga_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_shelf/manga_shelf_extension_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/catalog/manga_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/calendar/movie_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/admin/movie_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/barcode/movie_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/movie/integrations/collection_csv/movie_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/integrations/catalog/movie_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/calendar/music_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/admin/music_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/barcode/music_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/collection_csv/music_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/catalog/music_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/calendar/tv_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/activity/tv_activity_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/admin/tv_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/barcode/tv_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/collection_csv/tv_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/catalog/tv_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_watch_session_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_custom_episode_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_catalog_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_catalog_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_catalog_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_catalog_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_catalog_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_catalog_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_catalog_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_catalog_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/serial/comic_serial_authority_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/serial/manga_serial_authority_contributor.dart';
import 'package:collectarr_app/features/library/kinds/anime/vocabulary/anime_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/vocabulary/boardgame_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/movie/vocabulary/movie_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/music/vocabulary/music_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
import 'package:collectarr_app/features/library/config/library_activity_contributor.dart';
import 'package:collectarr_app/features/library/config/library_admin_contributor.dart';
import 'package:collectarr_app/features/library/config/library_barcode_resolver.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/config/library_shelf_extension_contributor.dart';
import 'package:collectarr_app/features/library/config/library_export_preview_contributor.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';
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

final Map<CatalogMediaKind, LibraryKindWorkspace> collectarrKindWorkspaces = {
  CatalogMediaKind.anime: animeKindWorkspace,
  CatalogMediaKind.boardgame: boardGameKindWorkspace,
  CatalogMediaKind.book: bookKindWorkspace,
  CatalogMediaKind.comic: comicKindWorkspace,
  CatalogMediaKind.game: gameKindWorkspace,
  CatalogMediaKind.manga: mangaKindWorkspace,
  CatalogMediaKind.movie: movieKindWorkspace,
  CatalogMediaKind.music: musicKindWorkspace,
  CatalogMediaKind.tv: tvKindWorkspace,
};

final collectarrKindCalendarContributors =
    <CatalogMediaKind, LibraryCalendarContributor>{
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

final collectarrKindActivityContributors =
    <CatalogMediaKind, LibraryActivityContributor>{
  CatalogMediaKind.anime: const AnimeActivityContributor(),
  CatalogMediaKind.tv: const TvActivityContributor(),
};

final collectarrKindAdminContributors =
    <CatalogMediaKind, LibraryAdminContributor>{
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

final collectarrKindBarcodeResolvers =
    <CatalogMediaKind, LibraryBarcodeResolver>{
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

final collectarrKindCollectionCsvProjections =
    <CatalogMediaKind, LibraryCollectionCsvProjection>{
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

final collectarrKindShelfExtensions =
    <CatalogMediaKind, LibraryShelfExtensionContributor>{
  CatalogMediaKind.manga: const MangaShelfExtensionContributor(),
};

final collectarrKindExportPreviewContributors =
    <CatalogMediaKind, LibraryExportPreviewContributor>{
  CatalogMediaKind.comic: const ComicExportPreviewContributor(),
};

final List<GoRoute> collectarrKindRoutes = [
  ComicRouteContributor().build(),
];

List<CatalogKindLookup> collectarrCatalogKindLookups(LocalDatabase db) => [
      AnimeCatalogLookup(db),
      BoardGameCatalogLookup(db),
      BookCatalogLookup(db),
      ComicCatalogLookup(db),
      GameCatalogLookup(db),
      MangaCatalogLookup(db),
      MovieCatalogLookup(db),
      MusicCatalogLookup(db),
      TvCatalogLookup(db),
    ];

const List<TrackingEntryCodec> collectarrTrackingEntryCodecs = [
  AnimeTrackingEntryCodec(),
  BoardGameTrackingEntryCodec(),
  BookTrackingEntryCodec(),
  ComicTrackingEntryCodec(),
  GameTrackingEntryCodec(),
  MangaTrackingEntryCodec(),
  MovieTrackingEntryCodec(),
  MusicTrackingEntryCodec(),
  TvTrackingEntryCodec(),
];

const List<TrackingUnitCodec> collectarrTrackingUnitCodecs = [
  AnimeTrackingUnitCodec(),
  BookTrackingUnitCodec(),
  ComicTrackingUnitCodec(),
  MangaTrackingUnitCodec(),
  TvTrackingUnitCodec(),
];

const List<WatchSessionCodec> collectarrWatchSessionCodecs = [
  AnimeWatchSessionCodec(),
  TvWatchSessionCodec(),
];

const List<CustomEpisodeCodec> collectarrCustomEpisodeCodecs = [
  AnimeCustomEpisodeCodec(),
  TvCustomEpisodeCodec(),
];

final collectarrKindProviderMappers =
    <CatalogMediaKind, LibraryKindProviderMapper>{
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

final collectarrKindOwnedDetailsCodecs =
    <CatalogMediaKind, OwnedDetailsPersistenceCodec>{
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
final collectarrKindMetadataDecoders =
    <CatalogMediaKind, Object? Function(Map<String, dynamic>)>{
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
final collectarrTypedOwnedItemPersisters =
    <CatalogMediaKind, Future<void> Function(LocalDatabase, Object)>{
  CatalogMediaKind.anime: (database, item) =>
      AnimeOwnedRepository(database).upsert(item as AnimeOwnedItem),
  CatalogMediaKind.boardgame: (database, item) =>
      BoardGameOwnedRepository(database).upsert(item as BoardGameOwnedItem),
  CatalogMediaKind.book: (database, item) =>
      BookOwnedRepository(database).upsert(item as BookOwnedItem),
  CatalogMediaKind.comic: (database, item) =>
      ComicOwnedRepository(database).upsert(item as ComicOwnedItem),
  CatalogMediaKind.game: (database, item) =>
      GameOwnedRepository(database).upsert(item as GameOwnedItem),
  CatalogMediaKind.manga: (database, item) =>
      MangaOwnedRepository(database).upsert(item as MangaOwnedItem),
  CatalogMediaKind.movie: (database, item) =>
      MovieOwnedRepository(database).upsert(item as MovieOwnedItem),
  CatalogMediaKind.music: (database, item) =>
      MusicOwnedRepository(database).upsert(item as MusicOwnedItem),
  CatalogMediaKind.tv: (database, item) =>
      TvOwnedRepository(database).upsert(item as TvOwnedItem),
};

final collectarrOwnedItemPersisters =
    <CatalogMediaKind, Future<void> Function(LocalDatabase, OwnedItem)>{
  CatalogMediaKind.anime: (database, item) => AnimeOwnedRepository(database)
      .upsert(AnimeOwnedItemProjection.fromOwnedItem(item)),
  CatalogMediaKind.boardgame: (database, item) =>
      BoardGameOwnedRepository(database)
          .upsert(BoardGameOwnedItemProjection.fromOwnedItem(item)),
  CatalogMediaKind.book: (database, item) => BookOwnedRepository(database)
      .upsert(BookOwnedItemProjection.fromOwnedItem(item)),
  CatalogMediaKind.comic: (database, item) => ComicOwnedRepository(database)
      .upsert(ComicOwnedItemProjection.fromOwnedItem(item)),
  CatalogMediaKind.game: (database, item) => GameOwnedRepository(database)
      .upsert(GameOwnedItemProjection.fromOwnedItem(item)),
  CatalogMediaKind.manga: (database, item) => MangaOwnedRepository(database)
      .upsert(MangaOwnedItemProjection.fromOwnedItem(item)),
  CatalogMediaKind.movie: (database, item) => MovieOwnedRepository(database)
      .upsert(MovieOwnedItemProjection.fromOwnedItem(item)),
  CatalogMediaKind.music: (database, item) => MusicOwnedRepository(database)
      .upsert(MusicOwnedItemProjection.fromOwnedItem(item)),
  CatalogMediaKind.tv: (database, item) => TvOwnedRepository(database)
      .upsert(TvOwnedItemProjection.fromOwnedItem(item)),
};

final collectarrTypedOwnedLocationUpdaters =
    <CatalogMediaKind, Future<void> Function(LocalDatabase, String, String?)>{
  CatalogMediaKind.anime: (database, id, locationId) async {
    final item =
        await AnimeOwnedRepository(database).findById(AnimeOwnedItemId(id));
    if (item == null) return;
    await AnimeOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
  },
  CatalogMediaKind.boardgame: (database, id, locationId) async {
    final item = await BoardGameOwnedRepository(database)
        .findById(BoardGameOwnedItemId(id));
    if (item == null) return;
    await BoardGameOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
  },
  CatalogMediaKind.book: (database, id, locationId) async {
    final item =
        await BookOwnedRepository(database).findById(BookOwnedItemId(id));
    if (item == null) return;
    await BookOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
  },
  CatalogMediaKind.comic: (database, id, locationId) async {
    final item =
        await ComicOwnedRepository(database).findById(ComicOwnedItemId(id));
    if (item == null) return;
    await ComicOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
  },
  CatalogMediaKind.game: (database, id, locationId) async {
    final item =
        await GameOwnedRepository(database).findById(GameOwnedItemId(id));
    if (item == null) return;
    await GameOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
  },
  CatalogMediaKind.manga: (database, id, locationId) async {
    final item =
        await MangaOwnedRepository(database).findById(MangaOwnedItemId(id));
    if (item == null) return;
    await MangaOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
  },
  CatalogMediaKind.movie: (database, id, locationId) async {
    final item =
        await MovieOwnedRepository(database).findById(MovieOwnedItemId(id));
    if (item == null) return;
    await MovieOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
  },
  CatalogMediaKind.music: (database, id, locationId) async {
    final item =
        await MusicOwnedRepository(database).findById(MusicOwnedItemId(id));
    if (item == null) return;
    await MusicOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
  },
  CatalogMediaKind.tv: (database, id, locationId) async {
    final item = await TvOwnedRepository(database).findById(TvOwnedItemId(id));
    if (item == null) return;
    await TvOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
  },
};

final collectarrTypedOwnedItemFinders =
    <CatalogMediaKind, Future<Object?> Function(LocalDatabase, String)>{
  CatalogMediaKind.anime: (database, id) =>
      AnimeOwnedRepository(database).findById(AnimeOwnedItemId(id)),
  CatalogMediaKind.boardgame: (database, id) =>
      BoardGameOwnedRepository(database).findById(BoardGameOwnedItemId(id)),
  CatalogMediaKind.book: (database, id) =>
      BookOwnedRepository(database).findById(BookOwnedItemId(id)),
  CatalogMediaKind.comic: (database, id) =>
      ComicOwnedRepository(database).findById(ComicOwnedItemId(id)),
  CatalogMediaKind.game: (database, id) =>
      GameOwnedRepository(database).findById(GameOwnedItemId(id)),
  CatalogMediaKind.manga: (database, id) =>
      MangaOwnedRepository(database).findById(MangaOwnedItemId(id)),
  CatalogMediaKind.movie: (database, id) =>
      MovieOwnedRepository(database).findById(MovieOwnedItemId(id)),
  CatalogMediaKind.music: (database, id) =>
      MusicOwnedRepository(database).findById(MusicOwnedItemId(id)),
  CatalogMediaKind.tv: (database, id) =>
      TvOwnedRepository(database).findById(TvOwnedItemId(id)),
};

final collectarrTypedOwnedItemDeleters =
    <CatalogMediaKind, Future<void> Function(LocalDatabase, Object, DateTime)>{
  CatalogMediaKind.anime: (database, item, deletedAt) =>
      AnimeOwnedRepository(database)
          .markDeleted(item as AnimeOwnedItem, deletedAt),
  CatalogMediaKind.boardgame: (database, item, deletedAt) =>
      BoardGameOwnedRepository(database)
          .markDeleted(item as BoardGameOwnedItem, deletedAt),
  CatalogMediaKind.book: (database, item, deletedAt) =>
      BookOwnedRepository(database)
          .markDeleted(item as BookOwnedItem, deletedAt),
  CatalogMediaKind.comic: (database, item, deletedAt) =>
      ComicOwnedRepository(database)
          .markDeleted(item as ComicOwnedItem, deletedAt),
  CatalogMediaKind.game: (database, item, deletedAt) =>
      GameOwnedRepository(database)
          .markDeleted(item as GameOwnedItem, deletedAt),
  CatalogMediaKind.manga: (database, item, deletedAt) =>
      MangaOwnedRepository(database)
          .markDeleted(item as MangaOwnedItem, deletedAt),
  CatalogMediaKind.movie: (database, item, deletedAt) =>
      MovieOwnedRepository(database)
          .markDeleted(item as MovieOwnedItem, deletedAt),
  CatalogMediaKind.music: (database, item, deletedAt) =>
      MusicOwnedRepository(database)
          .markDeleted(item as MusicOwnedItem, deletedAt),
  CatalogMediaKind.tv: (database, item, deletedAt) =>
      TvOwnedRepository(database).markDeleted(item as TvOwnedItem, deletedAt),
};

Future<(CatalogMediaKind kind, Object item)?> collectarrFindTypedOwnedItem(
    LocalDatabase database, String id) async {
  final animeItem =
      await AnimeOwnedRepository(database).findById(AnimeOwnedItemId(id));
  if (animeItem != null) return (CatalogMediaKind.anime, animeItem);
  final boardgameItem = await BoardGameOwnedRepository(database)
      .findById(BoardGameOwnedItemId(id));
  if (boardgameItem != null) return (CatalogMediaKind.boardgame, boardgameItem);
  final bookItem =
      await BookOwnedRepository(database).findById(BookOwnedItemId(id));
  if (bookItem != null) return (CatalogMediaKind.book, bookItem);
  final comicItem =
      await ComicOwnedRepository(database).findById(ComicOwnedItemId(id));
  if (comicItem != null) return (CatalogMediaKind.comic, comicItem);
  final gameItem =
      await GameOwnedRepository(database).findById(GameOwnedItemId(id));
  if (gameItem != null) return (CatalogMediaKind.game, gameItem);
  final mangaItem =
      await MangaOwnedRepository(database).findById(MangaOwnedItemId(id));
  if (mangaItem != null) return (CatalogMediaKind.manga, mangaItem);
  final movieItem =
      await MovieOwnedRepository(database).findById(MovieOwnedItemId(id));
  if (movieItem != null) return (CatalogMediaKind.movie, movieItem);
  final musicItem =
      await MusicOwnedRepository(database).findById(MusicOwnedItemId(id));
  if (musicItem != null) return (CatalogMediaKind.music, musicItem);
  final tvItem = await TvOwnedRepository(database).findById(TvOwnedItemId(id));
  if (tvItem != null) return (CatalogMediaKind.tv, tvItem);
  return null;
}

OwnedItemRef collectarrTypedOwnedItemRef(Object item) {
  if (item is AnimeOwnedItem)
    return OwnedItemRef(
        kind: CatalogMediaKind.anime, id: OwnedItemId(item.id.value));
  if (item is BoardGameOwnedItem)
    return OwnedItemRef(
        kind: CatalogMediaKind.boardgame, id: OwnedItemId(item.id.value));
  if (item is BookOwnedItem)
    return OwnedItemRef(
        kind: CatalogMediaKind.book, id: OwnedItemId(item.id.value));
  if (item is ComicOwnedItem)
    return OwnedItemRef(
        kind: CatalogMediaKind.comic, id: OwnedItemId(item.id.value));
  if (item is GameOwnedItem)
    return OwnedItemRef(
        kind: CatalogMediaKind.game, id: OwnedItemId(item.id.value));
  if (item is MangaOwnedItem)
    return OwnedItemRef(
        kind: CatalogMediaKind.manga, id: OwnedItemId(item.id.value));
  if (item is MovieOwnedItem)
    return OwnedItemRef(
        kind: CatalogMediaKind.movie, id: OwnedItemId(item.id.value));
  if (item is MusicOwnedItem)
    return OwnedItemRef(
        kind: CatalogMediaKind.music, id: OwnedItemId(item.id.value));
  if (item is TvOwnedItem)
    return OwnedItemRef(
        kind: CatalogMediaKind.tv, id: OwnedItemId(item.id.value));
  throw ArgumentError.value(item, 'item', 'Unsupported typed Owned seed');
}

Map<String, dynamic> collectarrTypedOwnedItemJson(Object item) {
  if (item is AnimeOwnedItem) return item.toJson();
  if (item is BoardGameOwnedItem) return item.toJson();
  if (item is BookOwnedItem) return item.toJson();
  if (item is ComicOwnedItem) return item.toJson();
  if (item is GameOwnedItem) return item.toJson();
  if (item is MangaOwnedItem) return item.toJson();
  if (item is MovieOwnedItem) return item.toJson();
  if (item is MusicOwnedItem) return item.toJson();
  if (item is TvOwnedItem) return item.toJson();
  throw ArgumentError.value(item, 'item', 'Unsupported typed Owned seed');
}

final collectarrTypedOwnedItemSyncSerializers = <CatalogMediaKind,
    ({Map<String, dynamic> payload, bool isDeleted}) Function(Object)>{
  CatalogMediaKind.anime: (item) {
    final payload =
        Map<String, dynamic>.from((item as AnimeOwnedItem).toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  },
  CatalogMediaKind.boardgame: (item) {
    final payload =
        Map<String, dynamic>.from((item as BoardGameOwnedItem).toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  },
  CatalogMediaKind.book: (item) {
    final payload = Map<String, dynamic>.from((item as BookOwnedItem).toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  },
  CatalogMediaKind.comic: (item) {
    final payload =
        Map<String, dynamic>.from((item as ComicOwnedItem).toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  },
  CatalogMediaKind.game: (item) {
    final payload = Map<String, dynamic>.from((item as GameOwnedItem).toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  },
  CatalogMediaKind.manga: (item) {
    final payload =
        Map<String, dynamic>.from((item as MangaOwnedItem).toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  },
  CatalogMediaKind.movie: (item) {
    final payload =
        Map<String, dynamic>.from((item as MovieOwnedItem).toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  },
  CatalogMediaKind.music: (item) {
    final payload =
        Map<String, dynamic>.from((item as MusicOwnedItem).toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  },
  CatalogMediaKind.tv: (item) {
    final payload = Map<String, dynamic>.from((item as TvOwnedItem).toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  },
};

final collectarrOwnedItemSerializers =
    <CatalogMediaKind, OwnedItem Function(Object)>{
  CatalogMediaKind.anime: (item) =>
      AnimeOwnedItemProjection.toOwnedItem(item as AnimeOwnedItem),
  CatalogMediaKind.boardgame: (item) =>
      BoardGameOwnedItemProjection.toOwnedItem(item as BoardGameOwnedItem),
  CatalogMediaKind.book: (item) =>
      BookOwnedItemProjection.toOwnedItem(item as BookOwnedItem),
  CatalogMediaKind.comic: (item) =>
      ComicOwnedItemProjection.toOwnedItem(item as ComicOwnedItem),
  CatalogMediaKind.game: (item) =>
      GameOwnedItemProjection.toOwnedItem(item as GameOwnedItem),
  CatalogMediaKind.manga: (item) =>
      MangaOwnedItemProjection.toOwnedItem(item as MangaOwnedItem),
  CatalogMediaKind.movie: (item) =>
      MovieOwnedItemProjection.toOwnedItem(item as MovieOwnedItem),
  CatalogMediaKind.music: (item) =>
      MusicOwnedItemProjection.toOwnedItem(item as MusicOwnedItem),
  CatalogMediaKind.tv: (item) =>
      TvOwnedItemProjection.toOwnedItem(item as TvOwnedItem),
};

final collectarrOwnedItemDeserializers =
    <CatalogMediaKind, Object Function(OwnedItem)>{
  CatalogMediaKind.anime: AnimeOwnedItemProjection.fromOwnedItem,
  CatalogMediaKind.boardgame: BoardGameOwnedItemProjection.fromOwnedItem,
  CatalogMediaKind.book: BookOwnedItemProjection.fromOwnedItem,
  CatalogMediaKind.comic: ComicOwnedItemProjection.fromOwnedItem,
  CatalogMediaKind.game: GameOwnedItemProjection.fromOwnedItem,
  CatalogMediaKind.manga: MangaOwnedItemProjection.fromOwnedItem,
  CatalogMediaKind.movie: MovieOwnedItemProjection.fromOwnedItem,
  CatalogMediaKind.music: MusicOwnedItemProjection.fromOwnedItem,
  CatalogMediaKind.tv: TvOwnedItemProjection.fromOwnedItem,
};

final collectarrOwnedItemReaders =
    <CatalogMediaKind, Future<List<OwnedItem>> Function(LocalDatabase)>{
  CatalogMediaKind.anime: (database) async =>
      (await AnimeOwnedRepository(database).listActive())
          .map(AnimeOwnedItemProjection.toOwnedItem)
          .toList(growable: false),
  CatalogMediaKind.boardgame: (database) async =>
      (await BoardGameOwnedRepository(database).listActive())
          .map(BoardGameOwnedItemProjection.toOwnedItem)
          .toList(growable: false),
  CatalogMediaKind.book: (database) async =>
      (await BookOwnedRepository(database).listActive())
          .map(BookOwnedItemProjection.toOwnedItem)
          .toList(growable: false),
  CatalogMediaKind.comic: (database) async =>
      (await ComicOwnedRepository(database).listActive())
          .map(ComicOwnedItemProjection.toOwnedItem)
          .toList(growable: false),
  CatalogMediaKind.game: (database) async =>
      (await GameOwnedRepository(database).listActive())
          .map(GameOwnedItemProjection.toOwnedItem)
          .toList(growable: false),
  CatalogMediaKind.manga: (database) async =>
      (await MangaOwnedRepository(database).listActive())
          .map(MangaOwnedItemProjection.toOwnedItem)
          .toList(growable: false),
  CatalogMediaKind.movie: (database) async =>
      (await MovieOwnedRepository(database).listActive())
          .map(MovieOwnedItemProjection.toOwnedItem)
          .toList(growable: false),
  CatalogMediaKind.music: (database) async =>
      (await MusicOwnedRepository(database).listActive())
          .map(MusicOwnedItemProjection.toOwnedItem)
          .toList(growable: false),
  CatalogMediaKind.tv: (database) async =>
      (await TvOwnedRepository(database).listActive())
          .map(TvOwnedItemProjection.toOwnedItem)
          .toList(growable: false),
};

final collectarrOwnedItemSummaryReaders =
    <CatalogMediaKind, Future<List<OwnedItemSummary>> Function(LocalDatabase)>{
  CatalogMediaKind.anime: (database) async =>
      (await AnimeOwnedRepository(database).listActive())
          .map(AnimeOwnedItemProjection.toSummary)
          .toList(growable: false),
  CatalogMediaKind.boardgame: (database) async =>
      (await BoardGameOwnedRepository(database).listActive())
          .map(BoardGameOwnedItemProjection.toSummary)
          .toList(growable: false),
  CatalogMediaKind.book: (database) async =>
      (await BookOwnedRepository(database).listActive())
          .map(BookOwnedItemProjection.toSummary)
          .toList(growable: false),
  CatalogMediaKind.comic: (database) async =>
      (await ComicOwnedRepository(database).listActive())
          .map(ComicOwnedItemProjection.toSummary)
          .toList(growable: false),
  CatalogMediaKind.game: (database) async =>
      (await GameOwnedRepository(database).listActive())
          .map(GameOwnedItemProjection.toSummary)
          .toList(growable: false),
  CatalogMediaKind.manga: (database) async =>
      (await MangaOwnedRepository(database).listActive())
          .map(MangaOwnedItemProjection.toSummary)
          .toList(growable: false),
  CatalogMediaKind.movie: (database) async =>
      (await MovieOwnedRepository(database).listActive())
          .map(MovieOwnedItemProjection.toSummary)
          .toList(growable: false),
  CatalogMediaKind.music: (database) async =>
      (await MusicOwnedRepository(database).listActive())
          .map(MusicOwnedItemProjection.toSummary)
          .toList(growable: false),
  CatalogMediaKind.tv: (database) async =>
      (await TvOwnedRepository(database).listActive())
          .map(TvOwnedItemProjection.toSummary)
          .toList(growable: false),
};

final collectarrOwnedItemFinders =
    <CatalogMediaKind, Future<OwnedItem?> Function(LocalDatabase, String)>{
  CatalogMediaKind.anime: (database, id) async => _collectarrOwnedToCommon(
      await AnimeOwnedRepository(database).findById(AnimeOwnedItemId(id)),
      AnimeOwnedItemProjection.toOwnedItem),
  CatalogMediaKind.boardgame: (database, id) async => _collectarrOwnedToCommon(
      await BoardGameOwnedRepository(database)
          .findById(BoardGameOwnedItemId(id)),
      BoardGameOwnedItemProjection.toOwnedItem),
  CatalogMediaKind.book: (database, id) async => _collectarrOwnedToCommon(
      await BookOwnedRepository(database).findById(BookOwnedItemId(id)),
      BookOwnedItemProjection.toOwnedItem),
  CatalogMediaKind.comic: (database, id) async => _collectarrOwnedToCommon(
      await ComicOwnedRepository(database).findById(ComicOwnedItemId(id)),
      ComicOwnedItemProjection.toOwnedItem),
  CatalogMediaKind.game: (database, id) async => _collectarrOwnedToCommon(
      await GameOwnedRepository(database).findById(GameOwnedItemId(id)),
      GameOwnedItemProjection.toOwnedItem),
  CatalogMediaKind.manga: (database, id) async => _collectarrOwnedToCommon(
      await MangaOwnedRepository(database).findById(MangaOwnedItemId(id)),
      MangaOwnedItemProjection.toOwnedItem),
  CatalogMediaKind.movie: (database, id) async => _collectarrOwnedToCommon(
      await MovieOwnedRepository(database).findById(MovieOwnedItemId(id)),
      MovieOwnedItemProjection.toOwnedItem),
  CatalogMediaKind.music: (database, id) async => _collectarrOwnedToCommon(
      await MusicOwnedRepository(database).findById(MusicOwnedItemId(id)),
      MusicOwnedItemProjection.toOwnedItem),
  CatalogMediaKind.tv: (database, id) async => _collectarrOwnedToCommon(
      await TvOwnedRepository(database).findById(TvOwnedItemId(id)),
      TvOwnedItemProjection.toOwnedItem),
};

final collectarrOwnedItemDeleters = <CatalogMediaKind,
    Future<void> Function(LocalDatabase, OwnedItem, DateTime)>{
  CatalogMediaKind.anime: (database, item, deletedAt) =>
      AnimeOwnedRepository(database)
          .markDeleted(AnimeOwnedItemProjection.fromOwnedItem(item), deletedAt),
  CatalogMediaKind.boardgame: (database, item, deletedAt) =>
      BoardGameOwnedRepository(database).markDeleted(
          BoardGameOwnedItemProjection.fromOwnedItem(item), deletedAt),
  CatalogMediaKind.book: (database, item, deletedAt) =>
      BookOwnedRepository(database)
          .markDeleted(BookOwnedItemProjection.fromOwnedItem(item), deletedAt),
  CatalogMediaKind.comic: (database, item, deletedAt) =>
      ComicOwnedRepository(database)
          .markDeleted(ComicOwnedItemProjection.fromOwnedItem(item), deletedAt),
  CatalogMediaKind.game: (database, item, deletedAt) =>
      GameOwnedRepository(database)
          .markDeleted(GameOwnedItemProjection.fromOwnedItem(item), deletedAt),
  CatalogMediaKind.manga: (database, item, deletedAt) =>
      MangaOwnedRepository(database)
          .markDeleted(MangaOwnedItemProjection.fromOwnedItem(item), deletedAt),
  CatalogMediaKind.movie: (database, item, deletedAt) =>
      MovieOwnedRepository(database)
          .markDeleted(MovieOwnedItemProjection.fromOwnedItem(item), deletedAt),
  CatalogMediaKind.music: (database, item, deletedAt) =>
      MusicOwnedRepository(database)
          .markDeleted(MusicOwnedItemProjection.fromOwnedItem(item), deletedAt),
  CatalogMediaKind.tv: (database, item, deletedAt) =>
      TvOwnedRepository(database)
          .markDeleted(TvOwnedItemProjection.fromOwnedItem(item), deletedAt),
};

OwnedItem? _collectarrOwnedToCommon<T>(
  T? item,
  OwnedItem Function(T item) project,
) {
  return item == null ? null : project(item);
}

const List<CatalogKindRepositoryCodec> collectarrKindCatalogRepositoryCodecs = [
  AnimeCatalogRepositoryCodec(),
  BoardGameCatalogRepositoryCodec(),
  BookCatalogRepositoryCodec(),
  ComicCatalogRepositoryCodec(),
  GameCatalogRepositoryCodec(),
  MangaCatalogRepositoryCodec(),
  MovieCatalogRepositoryCodec(),
  MusicCatalogRepositoryCodec(),
  TvCatalogRepositoryCodec(),
];
const List<SerialAuthorityContributor>
    collectarrKindSerialAuthorityContributors = [
  ComicSerialAuthorityContributor(),
  MangaSerialAuthorityContributor(),
];

const List<PickListDefinitionContributor>
    collectarrKindPickListDefinitionContributors = [
  VocabularyPickListDefinitionContributor(
      kind: CatalogMediaKind.anime,
      vocabularies: AnimeVocabularies.all,
      ownedValueCounter: AnimeVocabularies.countOwnedValue,
      ownedMergePreviewer: AnimeVocabularies.previewOwnedMerge,
      ownedMerger: AnimeVocabularies.applyOwnedMerge),
  VocabularyPickListDefinitionContributor(
      kind: CatalogMediaKind.boardgame,
      vocabularies: BoardGameVocabularies.all,
      ownedValueCounter: BoardGameVocabularies.countOwnedValue,
      ownedMergePreviewer: BoardGameVocabularies.previewOwnedMerge,
      ownedMerger: BoardGameVocabularies.applyOwnedMerge),
  VocabularyPickListDefinitionContributor(
      kind: CatalogMediaKind.book,
      vocabularies: BookVocabularies.all,
      ownedValueCounter: BookVocabularies.countOwnedValue,
      ownedMergePreviewer: BookVocabularies.previewOwnedMerge,
      ownedMerger: BookVocabularies.applyOwnedMerge),
  VocabularyPickListDefinitionContributor(
      kind: CatalogMediaKind.comic,
      vocabularies: ComicVocabularies.all,
      ownedValueCounter: ComicVocabularies.countOwnedValue,
      ownedMergePreviewer: ComicVocabularies.previewOwnedMerge,
      ownedMerger: ComicVocabularies.applyOwnedMerge),
  VocabularyPickListDefinitionContributor(
      kind: CatalogMediaKind.game,
      vocabularies: GameVocabularies.all,
      ownedValueCounter: GameVocabularies.countOwnedValue,
      ownedMergePreviewer: GameVocabularies.previewOwnedMerge,
      ownedMerger: GameVocabularies.applyOwnedMerge),
  VocabularyPickListDefinitionContributor(
      kind: CatalogMediaKind.manga,
      vocabularies: MangaVocabularies.all,
      ownedValueCounter: MangaVocabularies.countOwnedValue,
      ownedMergePreviewer: MangaVocabularies.previewOwnedMerge,
      ownedMerger: MangaVocabularies.applyOwnedMerge),
  VocabularyPickListDefinitionContributor(
      kind: CatalogMediaKind.movie,
      vocabularies: MovieVocabularies.all,
      ownedValueCounter: MovieVocabularies.countOwnedValue,
      ownedMergePreviewer: MovieVocabularies.previewOwnedMerge,
      ownedMerger: MovieVocabularies.applyOwnedMerge),
  VocabularyPickListDefinitionContributor(
      kind: CatalogMediaKind.music,
      vocabularies: MusicVocabularies.all,
      ownedValueCounter: MusicVocabularies.countOwnedValue,
      ownedMergePreviewer: MusicVocabularies.previewOwnedMerge,
      ownedMerger: MusicVocabularies.applyOwnedMerge),
  VocabularyPickListDefinitionContributor(
      kind: CatalogMediaKind.tv,
      vocabularies: TvVocabularies.all,
      ownedValueCounter: TvVocabularies.countOwnedValue,
      ownedMergePreviewer: TvVocabularies.previewOwnedMerge,
      ownedMerger: TvVocabularies.applyOwnedMerge),
];

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
  AnimeRegistration(),
  BoardgameRegistration(),
  BookRegistration(),
  ComicRegistration(),
  GameRegistration(),
  MangaRegistration(),
  MovieRegistration(),
  MusicRegistration(),
  TvRegistration(),
];

final class AnimeRegistration implements LibraryKindRegistration {
  const AnimeRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  LibraryKindIdentity get identity => animeKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return AnimeLibraryPage(
      type: animeKindModule,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: animeKindModule,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}

final class BoardgameRegistration implements LibraryKindRegistration {
  const BoardgameRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;

  @override
  LibraryKindIdentity get identity => boardGameKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return BoardGameLibraryPage(
      type: boardGameKindModule,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: boardGameKindModule,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}

final class BookRegistration implements LibraryKindRegistration {
  const BookRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  LibraryKindIdentity get identity => bookKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return BookLibraryPage(
      type: bookKindModule,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: bookKindModule,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}

final class ComicRegistration implements LibraryKindRegistration {
  const ComicRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.comic;

  @override
  LibraryKindIdentity get identity => comicKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return ComicLibraryPage(
      type: comicKindModule,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: comicKindModule,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}

final class GameRegistration implements LibraryKindRegistration {
  const GameRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  LibraryKindIdentity get identity => gameKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return GameLibraryPage(
      type: gameKindModule,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: gameKindModule,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}

final class MangaRegistration implements LibraryKindRegistration {
  const MangaRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.manga;

  @override
  LibraryKindIdentity get identity => mangaKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return MangaLibraryPage(
      type: mangaKindModule,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: mangaKindModule,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}

final class MovieRegistration implements LibraryKindRegistration {
  const MovieRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  LibraryKindIdentity get identity => movieKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return MovieLibraryPage(
      type: movieKindModule,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: movieKindModule,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}

final class MusicRegistration implements LibraryKindRegistration {
  const MusicRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  LibraryKindIdentity get identity => musicKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return MusicLibraryPage(
      type: musicKindModule,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: musicKindModule,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}

final class TvRegistration implements LibraryKindRegistration {
  const TvRegistration();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  LibraryKindIdentity get identity => tvKindModule.identity;

  @override
  Widget buildLibraryPage({
    required Widget topBar,
    required Color accent,
    required Uri routeUri,
    LibraryLayoutSnapshot? switchLayoutSnapshot,
  }) {
    return TvLibraryPage(
      type: tvKindModule,
      topBar: topBar,
      accent: accent,
      routeUri: routeUri,
      switchLayoutSnapshot: switchLayoutSnapshot,
    );
  }

  @override
  Widget buildAdd({
    required BuildContext context,
    required LibraryAddDialogRequest request,
  }) {
    return LibraryAddDialog(
      type: tvKindModule,
      accent: request.accent,
      initialQuery: request.initialQuery,
      initialBarcode: request.initialBarcode,
    );
  }

  @override
  Future<LibraryEditSelection?> openMediaEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.media,
    );
  }

  @override
  Future<LibraryEditSelection?> openReleaseEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.release,
    );
  }

  @override
  Future<LibraryEditSelection?> openOwnedEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
  }) {
    return _openEdit(
      context: context,
      request: request,
      scope: LibraryEditScope.all,
    );
  }

  Future<LibraryEditSelection?> _openEdit({
    required BuildContext context,
    required LibraryEditDialogRequest request,
    required LibraryEditScope scope,
  }) {
    return showLibraryEditDialog(
      context: context,
      request: request.copyWith(scope: scope),
    );
  }
}

LibraryKindRegistration libraryKindRegistrationForKind(CatalogMediaKind kind) {
  for (final registration in collectarrKindRegistrations) {
    if (registration.kind == kind) return registration;
  }
  throw ArgumentError(
    'No LibraryKindRegistration registered for kind "$kind"',
  );
}
