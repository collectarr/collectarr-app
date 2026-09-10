// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
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
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_custom_episode_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/calendar/boardgame_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/admin/boardgame_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/barcode/boardgame_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/collection_csv/boardgame_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/integrations/catalog/boardgame_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/provider/boardgame_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/calendar/book_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/admin/book_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/book/barcode/book_isbn_resolver.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/collection_csv/book_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/integrations/catalog/book_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/provider/book_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/calendar/comic_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/admin/comic_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/barcode/comic_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/collection_csv/comic_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/comic_info/comic_info_export.dart';
import 'package:collectarr_app/features/library/kinds/comic/integrations/catalog/comic_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/comic/detail/comic_route_contributor.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/tracking/comic_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/calendar/game_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/admin/game_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/game/barcode/game_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/collection_csv/game_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/integrations/catalog/game_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/game/tracking/game_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/provider/game_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/calendar/manga_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/admin/manga_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/barcode/manga_identifier_resolver.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_csv/manga_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_shelf/manga_shelf_extension_contributor.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/catalog/manga_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/tracking/manga_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/provider/manga_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/calendar/movie_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/admin/movie_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/movie/barcode/movie_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/movie/integrations/collection_csv/movie_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/integrations/catalog/movie_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/movie/tracking/movie_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/calendar/music_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/admin/music_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/music/barcode/music_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/collection_csv/music_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/catalog/music_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/music/tracking/music_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/calendar/tv_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/activity/tv_activity_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/admin/tv_admin_contributor.dart';
import 'package:collectarr_app/features/library/kinds/tv/barcode/tv_barcode_resolver.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/collection_csv/tv_collection_csv_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/integrations/catalog/tv_catalog_lookup.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_lifecycle_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_watch_session_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_custom_episode_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/anime_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_catalog_transport_codec.dart';
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
import 'package:collectarr_app/features/library/tracking/tracking_lifecycle_codec.dart';
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

final Map<CatalogMediaKind, LibraryKindModule> collectarrKindModulesByKind =
    Map.unmodifiable({
  CatalogMediaKind.anime: animeKindModule,
  CatalogMediaKind.boardgame: boardGameKindModule,
  CatalogMediaKind.book: bookKindModule,
  CatalogMediaKind.comic: comicKindModule,
  CatalogMediaKind.game: gameKindModule,
  CatalogMediaKind.manga: mangaKindModule,
  CatalogMediaKind.movie: movieKindModule,
  CatalogMediaKind.music: musicKindModule,
  CatalogMediaKind.tv: tvKindModule,
});

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

const List<TrackingLifecycleCodec> collectarrTrackingLifecycleCodecs = [
  AnimeTrackingLifecycleCodec(),
  BoardGameTrackingLifecycleCodec(),
  BookTrackingLifecycleCodec(),
  ComicTrackingLifecycleCodec(),
  GameTrackingLifecycleCodec(),
  MangaTrackingLifecycleCodec(),
  MovieTrackingLifecycleCodec(),
  MusicTrackingLifecycleCodec(),
  TvTrackingLifecycleCodec(),
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

final collectarrKindProviderMetadataMappers =
    <CatalogMediaKind, ProviderMetadataItemMapper>{
  CatalogMediaKind.anime:
      const AnimeLibraryKindProviderMapper().metadataItemFromEnvelope,
  CatalogMediaKind.boardgame:
      const BoardGameLibraryKindProviderMapper().metadataItemFromEnvelope,
  CatalogMediaKind.book:
      const BookLibraryKindProviderMapper().metadataItemFromEnvelope,
  CatalogMediaKind.comic:
      const ComicLibraryKindProviderMapper().metadataItemFromEnvelope,
  CatalogMediaKind.game:
      const GameLibraryKindProviderMapper().metadataItemFromEnvelope,
  CatalogMediaKind.manga:
      const MangaLibraryKindProviderMapper().metadataItemFromEnvelope,
  CatalogMediaKind.movie:
      const MovieLibraryKindProviderMapper().metadataItemFromEnvelope,
  CatalogMediaKind.music:
      const MusicLibraryKindProviderMapper().metadataItemFromEnvelope,
  CatalogMediaKind.tv:
      const TvLibraryKindProviderMapper().metadataItemFromEnvelope,
};

final collectarrKindProviderCorrectionBuilders =
    <CatalogMediaKind, ProviderCorrectionBuilder>{
  CatalogMediaKind.anime:
      const AnimeLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.boardgame:
      const BoardGameLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.book: const BookLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.comic:
      const ComicLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.game: const GameLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.manga:
      const MangaLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.movie:
      const MovieLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.music:
      const MusicLibraryKindProviderMapper().buildCorrections,
  CatalogMediaKind.tv: const TvLibraryKindProviderMapper().buildCorrections,
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
Future<void> collectarrUpsertTypedOwnedItem(
    LocalDatabase database, CatalogMediaKind kind, Object item) async {
  if (kind == CatalogMediaKind.anime) {
    if (item is! AnimeOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected AnimeOwnedItem for anime');
    await AnimeOwnedRepository(database).upsert(item);
    return;
  }
  if (kind == CatalogMediaKind.boardgame) {
    if (item is! BoardGameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BoardGameOwnedItem for boardgame');
    await BoardGameOwnedRepository(database).upsert(item);
    return;
  }
  if (kind == CatalogMediaKind.book) {
    if (item is! BookOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BookOwnedItem for book');
    await BookOwnedRepository(database).upsert(item);
    return;
  }
  if (kind == CatalogMediaKind.comic) {
    if (item is! ComicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected ComicOwnedItem for comic');
    await ComicOwnedRepository(database).upsert(item);
    return;
  }
  if (kind == CatalogMediaKind.game) {
    if (item is! GameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected GameOwnedItem for game');
    await GameOwnedRepository(database).upsert(item);
    return;
  }
  if (kind == CatalogMediaKind.manga) {
    if (item is! MangaOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MangaOwnedItem for manga');
    await MangaOwnedRepository(database).upsert(item);
    return;
  }
  if (kind == CatalogMediaKind.movie) {
    if (item is! MovieOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MovieOwnedItem for movie');
    await MovieOwnedRepository(database).upsert(item);
    return;
  }
  if (kind == CatalogMediaKind.music) {
    if (item is! MusicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MusicOwnedItem for music');
    await MusicOwnedRepository(database).upsert(item);
    return;
  }
  if (kind == CatalogMediaKind.tv) {
    if (item is! TvOwnedItem)
      throw ArgumentError.value(item, 'item', 'Expected TvOwnedItem for tv');
    await TvOwnedRepository(database).upsert(item);
    return;
  }
  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');
}

Future<void> collectarrUpdateTypedOwnedLocation(LocalDatabase database,
    CatalogMediaKind kind, String id, String? locationId) async {
  if (kind == CatalogMediaKind.anime) {
    final item =
        await AnimeOwnedRepository(database).findById(AnimeOwnedItemId(id));
    if (item == null) return;
    await AnimeOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
    return;
  }
  if (kind == CatalogMediaKind.boardgame) {
    final item = await BoardGameOwnedRepository(database)
        .findById(BoardGameOwnedItemId(id));
    if (item == null) return;
    await BoardGameOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
    return;
  }
  if (kind == CatalogMediaKind.book) {
    final item =
        await BookOwnedRepository(database).findById(BookOwnedItemId(id));
    if (item == null) return;
    await BookOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
    return;
  }
  if (kind == CatalogMediaKind.comic) {
    final item =
        await ComicOwnedRepository(database).findById(ComicOwnedItemId(id));
    if (item == null) return;
    await ComicOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
    return;
  }
  if (kind == CatalogMediaKind.game) {
    final item =
        await GameOwnedRepository(database).findById(GameOwnedItemId(id));
    if (item == null) return;
    await GameOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
    return;
  }
  if (kind == CatalogMediaKind.manga) {
    final item =
        await MangaOwnedRepository(database).findById(MangaOwnedItemId(id));
    if (item == null) return;
    await MangaOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
    return;
  }
  if (kind == CatalogMediaKind.movie) {
    final item =
        await MovieOwnedRepository(database).findById(MovieOwnedItemId(id));
    if (item == null) return;
    await MovieOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
    return;
  }
  if (kind == CatalogMediaKind.music) {
    final item =
        await MusicOwnedRepository(database).findById(MusicOwnedItemId(id));
    if (item == null) return;
    await MusicOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
    return;
  }
  if (kind == CatalogMediaKind.tv) {
    final item = await TvOwnedRepository(database).findById(TvOwnedItemId(id));
    if (item == null) return;
    await TvOwnedRepository(database)
        .upsert(item.copyWith(locationId: locationId));
    return;
  }
  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');
}

Future<(CatalogMediaKind kind, Object item)?> collectarrFindTypedOwnedItemByRef(
    LocalDatabase database, OwnedItemRef ref) async {
  if (ref.kind == CatalogMediaKind.anime) {
    final item = await AnimeOwnedRepository(database)
        .findById(AnimeOwnedItemId(ref.id.value));
    if (item == null) return null;
    return (CatalogMediaKind.anime, item);
  }
  if (ref.kind == CatalogMediaKind.boardgame) {
    final item = await BoardGameOwnedRepository(database)
        .findById(BoardGameOwnedItemId(ref.id.value));
    if (item == null) return null;
    return (CatalogMediaKind.boardgame, item);
  }
  if (ref.kind == CatalogMediaKind.book) {
    final item = await BookOwnedRepository(database)
        .findById(BookOwnedItemId(ref.id.value));
    if (item == null) return null;
    return (CatalogMediaKind.book, item);
  }
  if (ref.kind == CatalogMediaKind.comic) {
    final item = await ComicOwnedRepository(database)
        .findById(ComicOwnedItemId(ref.id.value));
    if (item == null) return null;
    return (CatalogMediaKind.comic, item);
  }
  if (ref.kind == CatalogMediaKind.game) {
    final item = await GameOwnedRepository(database)
        .findById(GameOwnedItemId(ref.id.value));
    if (item == null) return null;
    return (CatalogMediaKind.game, item);
  }
  if (ref.kind == CatalogMediaKind.manga) {
    final item = await MangaOwnedRepository(database)
        .findById(MangaOwnedItemId(ref.id.value));
    if (item == null) return null;
    return (CatalogMediaKind.manga, item);
  }
  if (ref.kind == CatalogMediaKind.movie) {
    final item = await MovieOwnedRepository(database)
        .findById(MovieOwnedItemId(ref.id.value));
    if (item == null) return null;
    return (CatalogMediaKind.movie, item);
  }
  if (ref.kind == CatalogMediaKind.music) {
    final item = await MusicOwnedRepository(database)
        .findById(MusicOwnedItemId(ref.id.value));
    if (item == null) return null;
    return (CatalogMediaKind.music, item);
  }
  if (ref.kind == CatalogMediaKind.tv) {
    final item =
        await TvOwnedRepository(database).findById(TvOwnedItemId(ref.id.value));
    if (item == null) return null;
    return (CatalogMediaKind.tv, item);
  }
  return null;
}

Future<void> collectarrMarkTypedOwnedItemDeleted(LocalDatabase database,
    CatalogMediaKind kind, Object item, DateTime deletedAt) async {
  if (kind == CatalogMediaKind.anime) {
    if (item is! AnimeOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected AnimeOwnedItem for anime');
    await AnimeOwnedRepository(database).markDeleted(item, deletedAt);
    return;
  }
  if (kind == CatalogMediaKind.boardgame) {
    if (item is! BoardGameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BoardGameOwnedItem for boardgame');
    await BoardGameOwnedRepository(database).markDeleted(item, deletedAt);
    return;
  }
  if (kind == CatalogMediaKind.book) {
    if (item is! BookOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BookOwnedItem for book');
    await BookOwnedRepository(database).markDeleted(item, deletedAt);
    return;
  }
  if (kind == CatalogMediaKind.comic) {
    if (item is! ComicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected ComicOwnedItem for comic');
    await ComicOwnedRepository(database).markDeleted(item, deletedAt);
    return;
  }
  if (kind == CatalogMediaKind.game) {
    if (item is! GameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected GameOwnedItem for game');
    await GameOwnedRepository(database).markDeleted(item, deletedAt);
    return;
  }
  if (kind == CatalogMediaKind.manga) {
    if (item is! MangaOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MangaOwnedItem for manga');
    await MangaOwnedRepository(database).markDeleted(item, deletedAt);
    return;
  }
  if (kind == CatalogMediaKind.movie) {
    if (item is! MovieOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MovieOwnedItem for movie');
    await MovieOwnedRepository(database).markDeleted(item, deletedAt);
    return;
  }
  if (kind == CatalogMediaKind.music) {
    if (item is! MusicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MusicOwnedItem for music');
    await MusicOwnedRepository(database).markDeleted(item, deletedAt);
    return;
  }
  if (kind == CatalogMediaKind.tv) {
    if (item is! TvOwnedItem)
      throw ArgumentError.value(item, 'item', 'Expected TvOwnedItem for tv');
    await TvOwnedRepository(database).markDeleted(item, deletedAt);
    return;
  }
  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');
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

bool? collectarrTypedOwnedItemIsDigital(Object item) {
  if (item is AnimeOwnedItem) return item.isDigital;
  if (item is BoardGameOwnedItem) return item.isDigital;
  if (item is BookOwnedItem) return item.isDigital;
  if (item is ComicOwnedItem) return item.isDigital;
  if (item is GameOwnedItem) return item.isDigital;
  if (item is MangaOwnedItem) return item.isDigital;
  if (item is MovieOwnedItem) return item.isDigital;
  if (item is MusicOwnedItem) return item.isDigital;
  if (item is TvOwnedItem) return item.isDigital;
  throw ArgumentError.value(item, 'item', 'Unsupported typed Owned seed');
}

({Map<String, dynamic> payload, bool isDeleted})
    collectarrTypedOwnedItemSyncPayload(CatalogMediaKind kind, Object item) {
  if (kind == CatalogMediaKind.anime) {
    if (item is! AnimeOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected AnimeOwnedItem for anime');
    final payload = Map<String, dynamic>.from(item.toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }
  if (kind == CatalogMediaKind.boardgame) {
    if (item is! BoardGameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BoardGameOwnedItem for boardgame');
    final payload = Map<String, dynamic>.from(item.toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }
  if (kind == CatalogMediaKind.book) {
    if (item is! BookOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BookOwnedItem for book');
    final payload = Map<String, dynamic>.from(item.toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }
  if (kind == CatalogMediaKind.comic) {
    if (item is! ComicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected ComicOwnedItem for comic');
    final payload = Map<String, dynamic>.from(item.toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }
  if (kind == CatalogMediaKind.game) {
    if (item is! GameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected GameOwnedItem for game');
    final payload = Map<String, dynamic>.from(item.toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }
  if (kind == CatalogMediaKind.manga) {
    if (item is! MangaOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MangaOwnedItem for manga');
    final payload = Map<String, dynamic>.from(item.toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }
  if (kind == CatalogMediaKind.movie) {
    if (item is! MovieOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MovieOwnedItem for movie');
    final payload = Map<String, dynamic>.from(item.toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }
  if (kind == CatalogMediaKind.music) {
    if (item is! MusicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MusicOwnedItem for music');
    final payload = Map<String, dynamic>.from(item.toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }
  if (kind == CatalogMediaKind.tv) {
    if (item is! TvOwnedItem)
      throw ArgumentError.value(item, 'item', 'Expected TvOwnedItem for tv');
    final payload = Map<String, dynamic>.from(item.toJson());
    final isDeleted = payload['deleted_at'] != null;
    payload.remove('id');
    payload.remove('updated_at');
    payload.remove('deleted_at');
    payload.remove('reading');
    return (payload: payload, isDeleted: isDeleted);
  }
  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');
}

Object collectarrTypedOwnedItemFromSyncPayload(
    CatalogMediaKind kind, Map<String, dynamic> payload) {
  if (kind == CatalogMediaKind.anime) return AnimeOwnedItem.fromJson(payload);
  if (kind == CatalogMediaKind.boardgame)
    return BoardGameOwnedItem.fromJson(payload);
  if (kind == CatalogMediaKind.book) return BookOwnedItem.fromJson(payload);
  if (kind == CatalogMediaKind.comic) return ComicOwnedItem.fromJson(payload);
  if (kind == CatalogMediaKind.game) return GameOwnedItem.fromJson(payload);
  if (kind == CatalogMediaKind.manga) return MangaOwnedItem.fromJson(payload);
  if (kind == CatalogMediaKind.movie) return MovieOwnedItem.fromJson(payload);
  if (kind == CatalogMediaKind.music) return MusicOwnedItem.fromJson(payload);
  if (kind == CatalogMediaKind.tv) return TvOwnedItem.fromJson(payload);
  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');
}

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

OwnedItemCreatePayload collectarrOwnedCreatePayloadFromTyped(
    CatalogMediaKind kind, Object item) {
  if (kind == CatalogMediaKind.anime) {
    if (item is! AnimeOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected AnimeOwnedItem for anime');
    return AnimeOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (kind == CatalogMediaKind.boardgame) {
    if (item is! BoardGameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BoardGameOwnedItem for boardgame');
    return BoardgameOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (kind == CatalogMediaKind.book) {
    if (item is! BookOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BookOwnedItem for book');
    return BookOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (kind == CatalogMediaKind.comic) {
    if (item is! ComicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected ComicOwnedItem for comic');
    return ComicOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (kind == CatalogMediaKind.game) {
    if (item is! GameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected GameOwnedItem for game');
    return GameOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (kind == CatalogMediaKind.manga) {
    if (item is! MangaOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MangaOwnedItem for manga');
    return MangaOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (kind == CatalogMediaKind.movie) {
    if (item is! MovieOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MovieOwnedItem for movie');
    return MovieOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (kind == CatalogMediaKind.music) {
    if (item is! MusicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MusicOwnedItem for music');
    return MusicOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (kind == CatalogMediaKind.tv) {
    if (item is! TvOwnedItem)
      throw ArgumentError.value(item, 'item', 'Expected TvOwnedItem for tv');
    return TvOwnedItemCreatePayload.fromTypedItem(item);
  }
  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');
}

const List<CatalogKindTransportCodec> collectarrKindCatalogTransportCodecs = [
  AnimeCatalogTransportCodec(),
  BoardGameCatalogTransportCodec(),
  BookCatalogTransportCodec(),
  ComicCatalogTransportCodec(),
  GameCatalogTransportCodec(),
  MangaCatalogTransportCodec(),
  MovieCatalogTransportCodec(),
  MusicCatalogTransportCodec(),
  TvCatalogTransportCodec(),
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

final Map<CatalogMediaKind, LibraryKindRegistration>
    collectarrKindRegistrations = Map.unmodifiable({
  CatalogMediaKind.anime: AnimeRegistration(),
  CatalogMediaKind.boardgame: BoardgameRegistration(),
  CatalogMediaKind.book: BookRegistration(),
  CatalogMediaKind.comic: ComicRegistration(),
  CatalogMediaKind.game: GameRegistration(),
  CatalogMediaKind.manga: MangaRegistration(),
  CatalogMediaKind.movie: MovieRegistration(),
  CatalogMediaKind.music: MusicRegistration(),
  CatalogMediaKind.tv: TvRegistration(),
});

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
      initialIdentifier: request.initialIdentifier,
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
      initialIdentifier: request.initialIdentifier,
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
      initialIdentifier: request.initialIdentifier,
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
      initialIdentifier: request.initialIdentifier,
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
      initialIdentifier: request.initialIdentifier,
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
      initialIdentifier: request.initialIdentifier,
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
      initialIdentifier: request.initialIdentifier,
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
      initialIdentifier: request.initialIdentifier,
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
      initialIdentifier: request.initialIdentifier,
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
  final registration = collectarrKindRegistrations[kind];
  if (registration != null) return registration;
  throw ArgumentError(
    'No LibraryKindRegistration registered for kind "$kind"',
  );
}
