// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: dart run tool/generate_kind_registries.dart

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/config/owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/config/owned_item_mutation_result.dart';
import 'package:collectarr_app/features/library/config/owned_item_update_payload.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_lookup.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_registration.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/config/presentation/library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_metadata_capability.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/config/library_hierarchy_capability.dart';
import 'package:collectarr_app/features/library/config/library_inspector_capability.dart';
import 'package:collectarr_app/features/library/config/library_edit_capability.dart';
import 'package:collectarr_app/features/library/config/library_transfer_capability.dart';
import 'package:collectarr_app/features/library/config/library_stats_capability.dart';
import 'package:collectarr_app/features/library/config/library_value_capability.dart';
import 'package:collectarr_app/features/library/config/library_relation_capability.dart';
import 'package:collectarr_app/features/library/config/library_ui_policy.dart';
import 'package:collectarr_app/features/library/config/library_linked_metadata_capability.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_projection_capability.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/config/library_kind_toolbar_module.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
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
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/ownership/boardgame_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_item_update_payload.dart';
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

final Map<CatalogMediaKind, List<PhysicalMediaFormat>>
    collectarrKindPhysicalMediaFormats =
    Map.unmodifiable(<CatalogMediaKind, List<PhysicalMediaFormat>>{
  CatalogMediaKind.anime: animeKindModule.physicalMediaFormats,
  CatalogMediaKind.boardgame: boardGameKindModule.physicalMediaFormats,
  CatalogMediaKind.book: bookKindModule.physicalMediaFormats,
  CatalogMediaKind.comic: comicKindModule.physicalMediaFormats,
  CatalogMediaKind.game: gameKindModule.physicalMediaFormats,
  CatalogMediaKind.manga: mangaKindModule.physicalMediaFormats,
  CatalogMediaKind.movie: movieKindModule.physicalMediaFormats,
  CatalogMediaKind.music: musicKindModule.physicalMediaFormats,
  CatalogMediaKind.tv: tvKindModule.physicalMediaFormats,
});

final Map<CatalogMediaKind, LibraryMediaPresentation>
    collectarrKindPresentations =
    Map.unmodifiable(<CatalogMediaKind, LibraryMediaPresentation>{
  CatalogMediaKind.anime: animeKindModule.presentation,
  CatalogMediaKind.boardgame: boardGameKindModule.presentation,
  CatalogMediaKind.book: bookKindModule.presentation,
  CatalogMediaKind.comic: comicKindModule.presentation,
  CatalogMediaKind.game: gameKindModule.presentation,
  CatalogMediaKind.manga: mangaKindModule.presentation,
  CatalogMediaKind.movie: movieKindModule.presentation,
  CatalogMediaKind.music: musicKindModule.presentation,
  CatalogMediaKind.tv: tvKindModule.presentation,
});

final Map<CatalogMediaKind, LibraryMetadataCapability> collectarrKindMetadata =
    Map.unmodifiable(<CatalogMediaKind, LibraryMetadataCapability>{
  CatalogMediaKind.anime: animeKindModule.metadata,
  CatalogMediaKind.boardgame: boardGameKindModule.metadata,
  CatalogMediaKind.book: bookKindModule.metadata,
  CatalogMediaKind.comic: comicKindModule.metadata,
  CatalogMediaKind.game: gameKindModule.metadata,
  CatalogMediaKind.manga: mangaKindModule.metadata,
  CatalogMediaKind.movie: movieKindModule.metadata,
  CatalogMediaKind.music: musicKindModule.metadata,
  CatalogMediaKind.tv: tvKindModule.metadata,
});

final Map<CatalogMediaKind, MediaTrackingProfile>
    collectarrKindTrackingProfiles =
    Map.unmodifiable(<CatalogMediaKind, MediaTrackingProfile>{
  CatalogMediaKind.anime: animeKindModule.trackingProfile,
  CatalogMediaKind.boardgame: boardGameKindModule.trackingProfile,
  CatalogMediaKind.book: bookKindModule.trackingProfile,
  CatalogMediaKind.comic: comicKindModule.trackingProfile,
  CatalogMediaKind.game: gameKindModule.trackingProfile,
  CatalogMediaKind.manga: mangaKindModule.trackingProfile,
  CatalogMediaKind.movie: movieKindModule.trackingProfile,
  CatalogMediaKind.music: musicKindModule.trackingProfile,
  CatalogMediaKind.tv: tvKindModule.trackingProfile,
});

final Map<CatalogMediaKind, LibraryHierarchyCapability>
    collectarrKindHierarchies =
    Map.unmodifiable(<CatalogMediaKind, LibraryHierarchyCapability>{
  CatalogMediaKind.anime: animeKindModule.hierarchy,
  CatalogMediaKind.boardgame: boardGameKindModule.hierarchy,
  CatalogMediaKind.book: bookKindModule.hierarchy,
  CatalogMediaKind.comic: comicKindModule.hierarchy,
  CatalogMediaKind.game: gameKindModule.hierarchy,
  CatalogMediaKind.manga: mangaKindModule.hierarchy,
  CatalogMediaKind.movie: movieKindModule.hierarchy,
  CatalogMediaKind.music: musicKindModule.hierarchy,
  CatalogMediaKind.tv: tvKindModule.hierarchy,
});

final Map<CatalogMediaKind, LibraryInspectorCapability>
    collectarrKindInspectors =
    Map.unmodifiable(<CatalogMediaKind, LibraryInspectorCapability>{
  CatalogMediaKind.anime: animeKindModule.inspector,
  CatalogMediaKind.boardgame: boardGameKindModule.inspector,
  CatalogMediaKind.book: bookKindModule.inspector,
  CatalogMediaKind.comic: comicKindModule.inspector,
  CatalogMediaKind.game: gameKindModule.inspector,
  CatalogMediaKind.manga: mangaKindModule.inspector,
  CatalogMediaKind.movie: movieKindModule.inspector,
  CatalogMediaKind.music: musicKindModule.inspector,
  CatalogMediaKind.tv: tvKindModule.inspector,
});

final Map<CatalogMediaKind, LibraryEditCapability> collectarrKindEdits =
    Map.unmodifiable(<CatalogMediaKind, LibraryEditCapability>{
  CatalogMediaKind.anime: animeKindModule.edit,
  CatalogMediaKind.boardgame: boardGameKindModule.edit,
  CatalogMediaKind.book: bookKindModule.edit,
  CatalogMediaKind.comic: comicKindModule.edit,
  CatalogMediaKind.game: gameKindModule.edit,
  CatalogMediaKind.manga: mangaKindModule.edit,
  CatalogMediaKind.movie: movieKindModule.edit,
  CatalogMediaKind.music: musicKindModule.edit,
  CatalogMediaKind.tv: tvKindModule.edit,
});

final Map<CatalogMediaKind, LibraryTransferCapability> collectarrKindTransfers =
    Map.unmodifiable(<CatalogMediaKind, LibraryTransferCapability>{
  CatalogMediaKind.anime: animeKindModule.transfer,
  CatalogMediaKind.boardgame: boardGameKindModule.transfer,
  CatalogMediaKind.book: bookKindModule.transfer,
  CatalogMediaKind.comic: comicKindModule.transfer,
  CatalogMediaKind.game: gameKindModule.transfer,
  CatalogMediaKind.manga: mangaKindModule.transfer,
  CatalogMediaKind.movie: movieKindModule.transfer,
  CatalogMediaKind.music: musicKindModule.transfer,
  CatalogMediaKind.tv: tvKindModule.transfer,
});

final Map<CatalogMediaKind, LibraryStatsCapability> collectarrKindStats =
    Map.unmodifiable(<CatalogMediaKind, LibraryStatsCapability>{
  CatalogMediaKind.anime: animeKindModule.stats,
  CatalogMediaKind.boardgame: boardGameKindModule.stats,
  CatalogMediaKind.book: bookKindModule.stats,
  CatalogMediaKind.comic: comicKindModule.stats,
  CatalogMediaKind.game: gameKindModule.stats,
  CatalogMediaKind.manga: mangaKindModule.stats,
  CatalogMediaKind.movie: movieKindModule.stats,
  CatalogMediaKind.music: musicKindModule.stats,
  CatalogMediaKind.tv: tvKindModule.stats,
});

final Map<CatalogMediaKind, LibraryValueCapability?> collectarrKindValues =
    Map.unmodifiable(<CatalogMediaKind, LibraryValueCapability?>{
  CatalogMediaKind.anime: animeKindModule.value,
  CatalogMediaKind.boardgame: boardGameKindModule.value,
  CatalogMediaKind.book: bookKindModule.value,
  CatalogMediaKind.comic: comicKindModule.value,
  CatalogMediaKind.game: gameKindModule.value,
  CatalogMediaKind.manga: mangaKindModule.value,
  CatalogMediaKind.movie: movieKindModule.value,
  CatalogMediaKind.music: musicKindModule.value,
  CatalogMediaKind.tv: tvKindModule.value,
});

final Map<CatalogMediaKind, LibraryRelationCapability?>
    collectarrKindRelations =
    Map.unmodifiable(<CatalogMediaKind, LibraryRelationCapability?>{
  CatalogMediaKind.anime: animeKindModule.relations,
  CatalogMediaKind.boardgame: boardGameKindModule.relations,
  CatalogMediaKind.book: bookKindModule.relations,
  CatalogMediaKind.comic: comicKindModule.relations,
  CatalogMediaKind.game: gameKindModule.relations,
  CatalogMediaKind.manga: mangaKindModule.relations,
  CatalogMediaKind.movie: movieKindModule.relations,
  CatalogMediaKind.music: musicKindModule.relations,
  CatalogMediaKind.tv: tvKindModule.relations,
});

final Map<CatalogMediaKind, LibraryUiPolicy> collectarrKindUiPolicies =
    Map.unmodifiable(<CatalogMediaKind, LibraryUiPolicy>{
  CatalogMediaKind.anime: animeKindModule.uiPolicy,
  CatalogMediaKind.boardgame: boardGameKindModule.uiPolicy,
  CatalogMediaKind.book: bookKindModule.uiPolicy,
  CatalogMediaKind.comic: comicKindModule.uiPolicy,
  CatalogMediaKind.game: gameKindModule.uiPolicy,
  CatalogMediaKind.manga: mangaKindModule.uiPolicy,
  CatalogMediaKind.movie: movieKindModule.uiPolicy,
  CatalogMediaKind.music: musicKindModule.uiPolicy,
  CatalogMediaKind.tv: tvKindModule.uiPolicy,
});

final Map<CatalogMediaKind, LibraryLinkedMetadataCapability>
    collectarrKindLinkedMetadata =
    Map.unmodifiable(<CatalogMediaKind, LibraryLinkedMetadataCapability>{
  CatalogMediaKind.anime: animeKindModule.linkedMetadata,
  CatalogMediaKind.boardgame: boardGameKindModule.linkedMetadata,
  CatalogMediaKind.book: bookKindModule.linkedMetadata,
  CatalogMediaKind.comic: comicKindModule.linkedMetadata,
  CatalogMediaKind.game: gameKindModule.linkedMetadata,
  CatalogMediaKind.manga: mangaKindModule.linkedMetadata,
  CatalogMediaKind.movie: movieKindModule.linkedMetadata,
  CatalogMediaKind.music: musicKindModule.linkedMetadata,
  CatalogMediaKind.tv: tvKindModule.linkedMetadata,
});

final Map<CatalogMediaKind, LibraryAddCapability> collectarrKindAdds =
    Map.unmodifiable(<CatalogMediaKind, LibraryAddCapability>{
  CatalogMediaKind.anime: animeKindModule.add,
  CatalogMediaKind.boardgame: boardGameKindModule.add,
  CatalogMediaKind.book: bookKindModule.add,
  CatalogMediaKind.comic: comicKindModule.add,
  CatalogMediaKind.game: gameKindModule.add,
  CatalogMediaKind.manga: mangaKindModule.add,
  CatalogMediaKind.movie: movieKindModule.add,
  CatalogMediaKind.music: musicKindModule.add,
  CatalogMediaKind.tv: tvKindModule.add,
});

final Map<CatalogMediaKind, TitleProjectionCapability<LibraryWorkspaceDto>>
    collectarrKindTitleCapabilities = Map.unmodifiable(<CatalogMediaKind,
        TitleProjectionCapability<LibraryWorkspaceDto>>{
  CatalogMediaKind.anime: animeKindModule.titleCapability,
  CatalogMediaKind.boardgame: boardGameKindModule.titleCapability,
  CatalogMediaKind.book: bookKindModule.titleCapability,
  CatalogMediaKind.comic: comicKindModule.titleCapability,
  CatalogMediaKind.game: gameKindModule.titleCapability,
  CatalogMediaKind.manga: mangaKindModule.titleCapability,
  CatalogMediaKind.movie: movieKindModule.titleCapability,
  CatalogMediaKind.music: musicKindModule.titleCapability,
  CatalogMediaKind.tv: tvKindModule.titleCapability,
});

final Map<CatalogMediaKind, ReleaseProjectionCapability<LibraryWorkspaceDto>?>
    collectarrKindReleaseCapabilities = Map.unmodifiable(<CatalogMediaKind,
        ReleaseProjectionCapability<LibraryWorkspaceDto>?>{
  CatalogMediaKind.anime: animeKindModule.releaseCapability,
  CatalogMediaKind.boardgame: boardGameKindModule.releaseCapability,
  CatalogMediaKind.book: bookKindModule.releaseCapability,
  CatalogMediaKind.comic: comicKindModule.releaseCapability,
  CatalogMediaKind.game: gameKindModule.releaseCapability,
  CatalogMediaKind.manga: mangaKindModule.releaseCapability,
  CatalogMediaKind.movie: movieKindModule.releaseCapability,
  CatalogMediaKind.music: musicKindModule.releaseCapability,
  CatalogMediaKind.tv: tvKindModule.releaseCapability,
});

final Map<CatalogMediaKind, LibraryKindToolbarModule?> collectarrKindToolbars =
    Map.unmodifiable(<CatalogMediaKind, LibraryKindToolbarModule?>{
  CatalogMediaKind.anime: animeKindModule.toolbar,
  CatalogMediaKind.boardgame: boardGameKindModule.toolbar,
  CatalogMediaKind.book: bookKindModule.toolbar,
  CatalogMediaKind.comic: comicKindModule.toolbar,
  CatalogMediaKind.game: gameKindModule.toolbar,
  CatalogMediaKind.manga: mangaKindModule.toolbar,
  CatalogMediaKind.movie: movieKindModule.toolbar,
  CatalogMediaKind.music: musicKindModule.toolbar,
  CatalogMediaKind.tv: tvKindModule.toolbar,
});

final Map<CatalogMediaKind, List<LibrarySearchTarget>>
    collectarrKindSearchTargetOptions =
    Map.unmodifiable(<CatalogMediaKind, List<LibrarySearchTarget>>{
  CatalogMediaKind.anime: animeKindModule.searchTargetOptions,
  CatalogMediaKind.boardgame: boardGameKindModule.searchTargetOptions,
  CatalogMediaKind.book: bookKindModule.searchTargetOptions,
  CatalogMediaKind.comic: comicKindModule.searchTargetOptions,
  CatalogMediaKind.game: gameKindModule.searchTargetOptions,
  CatalogMediaKind.manga: mangaKindModule.searchTargetOptions,
  CatalogMediaKind.movie: movieKindModule.searchTargetOptions,
  CatalogMediaKind.music: musicKindModule.searchTargetOptions,
  CatalogMediaKind.tv: tvKindModule.searchTargetOptions,
});

final Map<CatalogMediaKind, LibraryWorkspaceViewProfile>
    collectarrKindViewProfiles =
    Map.unmodifiable(<CatalogMediaKind, LibraryWorkspaceViewProfile>{
  CatalogMediaKind.anime: animeKindModule.viewProfile,
  CatalogMediaKind.boardgame: boardGameKindModule.viewProfile,
  CatalogMediaKind.book: bookKindModule.viewProfile,
  CatalogMediaKind.comic: comicKindModule.viewProfile,
  CatalogMediaKind.game: gameKindModule.viewProfile,
  CatalogMediaKind.manga: mangaKindModule.viewProfile,
  CatalogMediaKind.movie: movieKindModule.viewProfile,
  CatalogMediaKind.music: musicKindModule.viewProfile,
  CatalogMediaKind.tv: tvKindModule.viewProfile,
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
Future<OwnedItemMutationResult> collectarrCreateOwnedItem(
  LocalDatabase database,
  CatalogMediaKind kind,
  OwnedItemCreatePayload payload, {
  required CatalogEntityRef resolvedCatalogRef,
  required String id,
  required DateTime createdAt,
  required bool? existingIsDigital,
  required String? ownerUserId,
  required String? ownerLabel,
}) async {
  if (kind == CatalogMediaKind.anime) {
    if (payload is! AnimeOwnedItemCreatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected AnimeOwnedItemCreatePayload for anime');
    final item = payload.toOwnedItem(
        resolvedCatalogRef: resolvedCatalogRef,
        id: id,
        createdAt: createdAt,
        existingIsDigital: existingIsDigital,
        ownerUserId: ownerUserId,
        ownerLabel: ownerLabel);
    await AnimeOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.anime, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.anime, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.boardgame) {
    if (payload is! BoardgameOwnedItemCreatePayload)
      throw ArgumentError.value(payload, 'payload',
          'Expected BoardgameOwnedItemCreatePayload for boardgame');
    final item = payload.toOwnedItem(
        resolvedCatalogRef: resolvedCatalogRef,
        id: id,
        createdAt: createdAt,
        existingIsDigital: existingIsDigital,
        ownerUserId: ownerUserId,
        ownerLabel: ownerLabel);
    await BoardGameOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.boardgame, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.boardgame, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.book) {
    if (payload is! BookOwnedItemCreatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected BookOwnedItemCreatePayload for book');
    final item = payload.toOwnedItem(
        resolvedCatalogRef: resolvedCatalogRef,
        id: id,
        createdAt: createdAt,
        existingIsDigital: existingIsDigital,
        ownerUserId: ownerUserId,
        ownerLabel: ownerLabel);
    await BookOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.book, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.book, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.comic) {
    if (payload is! ComicOwnedItemCreatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected ComicOwnedItemCreatePayload for comic');
    final item = payload.toOwnedItem(
        resolvedCatalogRef: resolvedCatalogRef,
        id: id,
        createdAt: createdAt,
        existingIsDigital: existingIsDigital,
        ownerUserId: ownerUserId,
        ownerLabel: ownerLabel);
    await ComicOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.comic, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.comic, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.game) {
    if (payload is! GameOwnedItemCreatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected GameOwnedItemCreatePayload for game');
    final item = payload.toOwnedItem(
        resolvedCatalogRef: resolvedCatalogRef,
        id: id,
        createdAt: createdAt,
        existingIsDigital: existingIsDigital,
        ownerUserId: ownerUserId,
        ownerLabel: ownerLabel);
    await GameOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.game, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.game, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.manga) {
    if (payload is! MangaOwnedItemCreatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected MangaOwnedItemCreatePayload for manga');
    final item = payload.toOwnedItem(
        resolvedCatalogRef: resolvedCatalogRef,
        id: id,
        createdAt: createdAt,
        existingIsDigital: existingIsDigital,
        ownerUserId: ownerUserId,
        ownerLabel: ownerLabel);
    await MangaOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.manga, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.manga, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.movie) {
    if (payload is! MovieOwnedItemCreatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected MovieOwnedItemCreatePayload for movie');
    final item = payload.toOwnedItem(
        resolvedCatalogRef: resolvedCatalogRef,
        id: id,
        createdAt: createdAt,
        existingIsDigital: existingIsDigital,
        ownerUserId: ownerUserId,
        ownerLabel: ownerLabel);
    await MovieOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.movie, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.movie, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.music) {
    if (payload is! MusicOwnedItemCreatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected MusicOwnedItemCreatePayload for music');
    final item = payload.toOwnedItem(
        resolvedCatalogRef: resolvedCatalogRef,
        id: id,
        createdAt: createdAt,
        existingIsDigital: existingIsDigital,
        ownerUserId: ownerUserId,
        ownerLabel: ownerLabel);
    await MusicOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.music, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.music, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.tv) {
    if (payload is! TvOwnedItemCreatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected TvOwnedItemCreatePayload for tv');
    final item = payload.toOwnedItem(
        resolvedCatalogRef: resolvedCatalogRef,
        id: id,
        createdAt: createdAt,
        existingIsDigital: existingIsDigital,
        ownerUserId: ownerUserId,
        ownerLabel: ownerLabel);
    await TvOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.tv, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.tv, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');
}

Future<OwnedItemMutationResult> collectarrUpdateOwnedItem(
  LocalDatabase database,
  OwnedItemRef ref,
  OwnedItemUpdatePayload payload, {
  required DateTime updatedAt,
  required String? fallbackOwnerUserId,
  required String? fallbackOwnerLabel,
}) async {
  if (ref.kind == CatalogMediaKind.anime) {
    final existing = await AnimeOwnedRepository(database)
        .findById(AnimeOwnedItemId(ref.id.value));
    if (existing == null) throw StateError('Owned item not found');
    if (payload is! AnimeOwnedItemUpdatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected AnimeOwnedItemUpdatePayload for anime');
    if (!payload.canApplyTo(existing))
      throw StateError('Owned update payload does not belong to anime');
    final updated = payload.applyTo(existing,
        updatedAt: updatedAt,
        fallbackOwnerUserId: fallbackOwnerUserId,
        fallbackOwnerLabel: fallbackOwnerLabel);
    await AnimeOwnedRepository(database).upsert(updated);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.anime, updated);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.anime, id: OwnedItemId(updated.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.boardgame) {
    final existing = await BoardGameOwnedRepository(database)
        .findById(BoardGameOwnedItemId(ref.id.value));
    if (existing == null) throw StateError('Owned item not found');
    if (payload is! BoardgameOwnedItemUpdatePayload)
      throw ArgumentError.value(payload, 'payload',
          'Expected BoardgameOwnedItemUpdatePayload for boardgame');
    if (!payload.canApplyTo(existing))
      throw StateError('Owned update payload does not belong to boardgame');
    final updated = payload.applyTo(existing,
        updatedAt: updatedAt,
        fallbackOwnerUserId: fallbackOwnerUserId,
        fallbackOwnerLabel: fallbackOwnerLabel);
    await BoardGameOwnedRepository(database).upsert(updated);
    final serialized = collectarrTypedOwnedItemSyncPayload(
        CatalogMediaKind.boardgame, updated);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.boardgame,
            id: OwnedItemId(updated.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.book) {
    final existing = await BookOwnedRepository(database)
        .findById(BookOwnedItemId(ref.id.value));
    if (existing == null) throw StateError('Owned item not found');
    if (payload is! BookOwnedItemUpdatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected BookOwnedItemUpdatePayload for book');
    if (!payload.canApplyTo(existing))
      throw StateError('Owned update payload does not belong to book');
    final updated = payload.applyTo(existing,
        updatedAt: updatedAt,
        fallbackOwnerUserId: fallbackOwnerUserId,
        fallbackOwnerLabel: fallbackOwnerLabel);
    await BookOwnedRepository(database).upsert(updated);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.book, updated);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.book, id: OwnedItemId(updated.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.comic) {
    final existing = await ComicOwnedRepository(database)
        .findById(ComicOwnedItemId(ref.id.value));
    if (existing == null) throw StateError('Owned item not found');
    if (payload is! ComicOwnedItemUpdatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected ComicOwnedItemUpdatePayload for comic');
    if (!payload.canApplyTo(existing))
      throw StateError('Owned update payload does not belong to comic');
    final updated = payload.applyTo(existing,
        updatedAt: updatedAt,
        fallbackOwnerUserId: fallbackOwnerUserId,
        fallbackOwnerLabel: fallbackOwnerLabel);
    await ComicOwnedRepository(database).upsert(updated);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.comic, updated);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.comic, id: OwnedItemId(updated.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.game) {
    final existing = await GameOwnedRepository(database)
        .findById(GameOwnedItemId(ref.id.value));
    if (existing == null) throw StateError('Owned item not found');
    if (payload is! GameOwnedItemUpdatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected GameOwnedItemUpdatePayload for game');
    if (!payload.canApplyTo(existing))
      throw StateError('Owned update payload does not belong to game');
    final updated = payload.applyTo(existing,
        updatedAt: updatedAt,
        fallbackOwnerUserId: fallbackOwnerUserId,
        fallbackOwnerLabel: fallbackOwnerLabel);
    await GameOwnedRepository(database).upsert(updated);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.game, updated);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.game, id: OwnedItemId(updated.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.manga) {
    final existing = await MangaOwnedRepository(database)
        .findById(MangaOwnedItemId(ref.id.value));
    if (existing == null) throw StateError('Owned item not found');
    if (payload is! MangaOwnedItemUpdatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected MangaOwnedItemUpdatePayload for manga');
    if (!payload.canApplyTo(existing))
      throw StateError('Owned update payload does not belong to manga');
    final updated = payload.applyTo(existing,
        updatedAt: updatedAt,
        fallbackOwnerUserId: fallbackOwnerUserId,
        fallbackOwnerLabel: fallbackOwnerLabel);
    await MangaOwnedRepository(database).upsert(updated);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.manga, updated);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.manga, id: OwnedItemId(updated.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.movie) {
    final existing = await MovieOwnedRepository(database)
        .findById(MovieOwnedItemId(ref.id.value));
    if (existing == null) throw StateError('Owned item not found');
    if (payload is! MovieOwnedItemUpdatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected MovieOwnedItemUpdatePayload for movie');
    if (!payload.canApplyTo(existing))
      throw StateError('Owned update payload does not belong to movie');
    final updated = payload.applyTo(existing,
        updatedAt: updatedAt,
        fallbackOwnerUserId: fallbackOwnerUserId,
        fallbackOwnerLabel: fallbackOwnerLabel);
    await MovieOwnedRepository(database).upsert(updated);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.movie, updated);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.movie, id: OwnedItemId(updated.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.music) {
    final existing = await MusicOwnedRepository(database)
        .findById(MusicOwnedItemId(ref.id.value));
    if (existing == null) throw StateError('Owned item not found');
    if (payload is! MusicOwnedItemUpdatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected MusicOwnedItemUpdatePayload for music');
    if (!payload.canApplyTo(existing))
      throw StateError('Owned update payload does not belong to music');
    final updated = payload.applyTo(existing,
        updatedAt: updatedAt,
        fallbackOwnerUserId: fallbackOwnerUserId,
        fallbackOwnerLabel: fallbackOwnerLabel);
    await MusicOwnedRepository(database).upsert(updated);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.music, updated);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.music, id: OwnedItemId(updated.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.tv) {
    final existing =
        await TvOwnedRepository(database).findById(TvOwnedItemId(ref.id.value));
    if (existing == null) throw StateError('Owned item not found');
    if (payload is! TvOwnedItemUpdatePayload)
      throw ArgumentError.value(
          payload, 'payload', 'Expected TvOwnedItemUpdatePayload for tv');
    if (!payload.canApplyTo(existing))
      throw StateError('Owned update payload does not belong to tv');
    final updated = payload.applyTo(existing,
        updatedAt: updatedAt,
        fallbackOwnerUserId: fallbackOwnerUserId,
        fallbackOwnerLabel: fallbackOwnerLabel);
    await TvOwnedRepository(database).upsert(updated);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.tv, updated);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.tv, id: OwnedItemId(updated.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  throw ArgumentError.value(ref.kind, 'ref', 'Unsupported owned kind');
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

Future<LibraryOwnedItemDispatch?> collectarrOwnedItemForLibraryByRef(
    LocalDatabase database, OwnedItemRef ref) async {
  if (ref.kind == CatalogMediaKind.anime) {
    final item = await AnimeOwnedRepository(database)
        .findById(AnimeOwnedItemId(ref.id.value));
    if (item == null) return null;
    return AnimeOwnedItemDispatch(ref: ref, value: item);
  }
  if (ref.kind == CatalogMediaKind.boardgame) {
    final item = await BoardGameOwnedRepository(database)
        .findById(BoardGameOwnedItemId(ref.id.value));
    if (item == null) return null;
    return BoardGameOwnedItemDispatch(ref: ref, value: item);
  }
  if (ref.kind == CatalogMediaKind.book) {
    final item = await BookOwnedRepository(database)
        .findById(BookOwnedItemId(ref.id.value));
    if (item == null) return null;
    return BookOwnedItemDispatch(ref: ref, value: item);
  }
  if (ref.kind == CatalogMediaKind.comic) {
    final item = await ComicOwnedRepository(database)
        .findById(ComicOwnedItemId(ref.id.value));
    if (item == null) return null;
    return ComicOwnedItemDispatch(ref: ref, value: item);
  }
  if (ref.kind == CatalogMediaKind.game) {
    final item = await GameOwnedRepository(database)
        .findById(GameOwnedItemId(ref.id.value));
    if (item == null) return null;
    return GameOwnedItemDispatch(ref: ref, value: item);
  }
  if (ref.kind == CatalogMediaKind.manga) {
    final item = await MangaOwnedRepository(database)
        .findById(MangaOwnedItemId(ref.id.value));
    if (item == null) return null;
    return MangaOwnedItemDispatch(ref: ref, value: item);
  }
  if (ref.kind == CatalogMediaKind.movie) {
    final item = await MovieOwnedRepository(database)
        .findById(MovieOwnedItemId(ref.id.value));
    if (item == null) return null;
    return MovieOwnedItemDispatch(ref: ref, value: item);
  }
  if (ref.kind == CatalogMediaKind.music) {
    final item = await MusicOwnedRepository(database)
        .findById(MusicOwnedItemId(ref.id.value));
    if (item == null) return null;
    return MusicOwnedItemDispatch(ref: ref, value: item);
  }
  if (ref.kind == CatalogMediaKind.tv) {
    final item =
        await TvOwnedRepository(database).findById(TvOwnedItemId(ref.id.value));
    if (item == null) return null;
    return TvOwnedItemDispatch(ref: ref, value: item);
  }
  return null;
}

Future<JsonMap?> collectarrOwnedItemJsonByRef(
    LocalDatabase database, OwnedItemRef ref) async {
  if (ref.kind == CatalogMediaKind.anime) {
    final item = await AnimeOwnedRepository(database)
        .findById(AnimeOwnedItemId(ref.id.value));
    return item?.toJson();
  }
  if (ref.kind == CatalogMediaKind.boardgame) {
    final item = await BoardGameOwnedRepository(database)
        .findById(BoardGameOwnedItemId(ref.id.value));
    return item?.toJson();
  }
  if (ref.kind == CatalogMediaKind.book) {
    final item = await BookOwnedRepository(database)
        .findById(BookOwnedItemId(ref.id.value));
    return item?.toJson();
  }
  if (ref.kind == CatalogMediaKind.comic) {
    final item = await ComicOwnedRepository(database)
        .findById(ComicOwnedItemId(ref.id.value));
    return item?.toJson();
  }
  if (ref.kind == CatalogMediaKind.game) {
    final item = await GameOwnedRepository(database)
        .findById(GameOwnedItemId(ref.id.value));
    return item?.toJson();
  }
  if (ref.kind == CatalogMediaKind.manga) {
    final item = await MangaOwnedRepository(database)
        .findById(MangaOwnedItemId(ref.id.value));
    return item?.toJson();
  }
  if (ref.kind == CatalogMediaKind.movie) {
    final item = await MovieOwnedRepository(database)
        .findById(MovieOwnedItemId(ref.id.value));
    return item?.toJson();
  }
  if (ref.kind == CatalogMediaKind.music) {
    final item = await MusicOwnedRepository(database)
        .findById(MusicOwnedItemId(ref.id.value));
    return item?.toJson();
  }
  if (ref.kind == CatalogMediaKind.tv) {
    final item =
        await TvOwnedRepository(database).findById(TvOwnedItemId(ref.id.value));
    return item?.toJson();
  }
  return null;
}

Future<({JsonMap payload, bool isDeleted})?>
    collectarrOwnedItemSyncPayloadByRef(
        LocalDatabase database, OwnedItemRef ref) async {
  if (ref.kind == CatalogMediaKind.anime) {
    final item = await AnimeOwnedRepository(database)
        .findById(AnimeOwnedItemId(ref.id.value));
    if (item == null) return null;
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.anime, item);
    return (payload: serialized.payload, isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.boardgame) {
    final item = await BoardGameOwnedRepository(database)
        .findById(BoardGameOwnedItemId(ref.id.value));
    if (item == null) return null;
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.boardgame, item);
    return (payload: serialized.payload, isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.book) {
    final item = await BookOwnedRepository(database)
        .findById(BookOwnedItemId(ref.id.value));
    if (item == null) return null;
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.book, item);
    return (payload: serialized.payload, isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.comic) {
    final item = await ComicOwnedRepository(database)
        .findById(ComicOwnedItemId(ref.id.value));
    if (item == null) return null;
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.comic, item);
    return (payload: serialized.payload, isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.game) {
    final item = await GameOwnedRepository(database)
        .findById(GameOwnedItemId(ref.id.value));
    if (item == null) return null;
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.game, item);
    return (payload: serialized.payload, isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.manga) {
    final item = await MangaOwnedRepository(database)
        .findById(MangaOwnedItemId(ref.id.value));
    if (item == null) return null;
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.manga, item);
    return (payload: serialized.payload, isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.movie) {
    final item = await MovieOwnedRepository(database)
        .findById(MovieOwnedItemId(ref.id.value));
    if (item == null) return null;
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.movie, item);
    return (payload: serialized.payload, isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.music) {
    final item = await MusicOwnedRepository(database)
        .findById(MusicOwnedItemId(ref.id.value));
    if (item == null) return null;
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.music, item);
    return (payload: serialized.payload, isDeleted: serialized.isDeleted);
  }
  if (ref.kind == CatalogMediaKind.tv) {
    final item =
        await TvOwnedRepository(database).findById(TvOwnedItemId(ref.id.value));
    if (item == null) return null;
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.tv, item);
    return (payload: serialized.payload, isDeleted: serialized.isDeleted);
  }
  return null;
}

Future<OwnedItemMutationResult> collectarrReplaceOwnedFromJson(
    LocalDatabase database, CatalogMediaKind kind, JsonMap payload) async {
  if (kind == CatalogMediaKind.anime) {
    final item = AnimeOwnedItem.fromJson(payload);
    await AnimeOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.anime, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.anime, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.boardgame) {
    final item = BoardGameOwnedItem.fromJson(payload);
    await BoardGameOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.boardgame, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.boardgame, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.book) {
    final item = BookOwnedItem.fromJson(payload);
    await BookOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.book, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.book, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.comic) {
    final item = ComicOwnedItem.fromJson(payload);
    await ComicOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.comic, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.comic, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.game) {
    final item = GameOwnedItem.fromJson(payload);
    await GameOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.game, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.game, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.manga) {
    final item = MangaOwnedItem.fromJson(payload);
    await MangaOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.manga, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.manga, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.movie) {
    final item = MovieOwnedItem.fromJson(payload);
    await MovieOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.movie, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.movie, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.music) {
    final item = MusicOwnedItem.fromJson(payload);
    await MusicOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.music, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.music, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  if (kind == CatalogMediaKind.tv) {
    final item = TvOwnedItem.fromJson(payload);
    await TvOwnedRepository(database).upsert(item);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.tv, item);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.tv, id: OwnedItemId(item.id.value)),
        syncPayload: serialized.payload,
        isDeleted: serialized.isDeleted);
  }
  throw ArgumentError.value(kind, 'kind', 'Unsupported owned kind');
}

Future<OwnedItemMutationResult?> collectarrMarkTypedOwnedItemDeleted(
    LocalDatabase database,
    CatalogMediaKind kind,
    Object item,
    DateTime deletedAt) async {
  if (kind == CatalogMediaKind.anime) {
    if (item is! AnimeOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected AnimeOwnedItem for anime');
    await AnimeOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.anime, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.anime, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (kind == CatalogMediaKind.boardgame) {
    if (item is! BoardGameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BoardGameOwnedItem for boardgame');
    await BoardGameOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized = collectarrTypedOwnedItemSyncPayload(
        CatalogMediaKind.boardgame, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.boardgame,
            id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (kind == CatalogMediaKind.book) {
    if (item is! BookOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected BookOwnedItem for book');
    await BookOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.book, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.book, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (kind == CatalogMediaKind.comic) {
    if (item is! ComicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected ComicOwnedItem for comic');
    await ComicOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.comic, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.comic, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (kind == CatalogMediaKind.game) {
    if (item is! GameOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected GameOwnedItem for game');
    await GameOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.game, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.game, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (kind == CatalogMediaKind.manga) {
    if (item is! MangaOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MangaOwnedItem for manga');
    await MangaOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.manga, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.manga, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (kind == CatalogMediaKind.movie) {
    if (item is! MovieOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MovieOwnedItem for movie');
    await MovieOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.movie, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.movie, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (kind == CatalogMediaKind.music) {
    if (item is! MusicOwnedItem)
      throw ArgumentError.value(
          item, 'item', 'Expected MusicOwnedItem for music');
    await MusicOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.music, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.music, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (kind == CatalogMediaKind.tv) {
    if (item is! TvOwnedItem)
      throw ArgumentError.value(item, 'item', 'Expected TvOwnedItem for tv');
    await TvOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.tv, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.tv, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  return null;
}

Future<OwnedItemMutationResult?> collectarrMarkOwnedItemDeletedByRef(
    LocalDatabase database, OwnedItemRef ref, DateTime deletedAt) async {
  if (ref.kind == CatalogMediaKind.anime) {
    final item = await AnimeOwnedRepository(database)
        .findById(AnimeOwnedItemId(ref.id.value));
    if (item == null) return null;
    await AnimeOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.anime, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.anime, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (ref.kind == CatalogMediaKind.boardgame) {
    final item = await BoardGameOwnedRepository(database)
        .findById(BoardGameOwnedItemId(ref.id.value));
    if (item == null) return null;
    await BoardGameOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized = collectarrTypedOwnedItemSyncPayload(
        CatalogMediaKind.boardgame, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.boardgame,
            id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (ref.kind == CatalogMediaKind.book) {
    final item = await BookOwnedRepository(database)
        .findById(BookOwnedItemId(ref.id.value));
    if (item == null) return null;
    await BookOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.book, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.book, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (ref.kind == CatalogMediaKind.comic) {
    final item = await ComicOwnedRepository(database)
        .findById(ComicOwnedItemId(ref.id.value));
    if (item == null) return null;
    await ComicOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.comic, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.comic, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (ref.kind == CatalogMediaKind.game) {
    final item = await GameOwnedRepository(database)
        .findById(GameOwnedItemId(ref.id.value));
    if (item == null) return null;
    await GameOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.game, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.game, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (ref.kind == CatalogMediaKind.manga) {
    final item = await MangaOwnedRepository(database)
        .findById(MangaOwnedItemId(ref.id.value));
    if (item == null) return null;
    await MangaOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.manga, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.manga, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (ref.kind == CatalogMediaKind.movie) {
    final item = await MovieOwnedRepository(database)
        .findById(MovieOwnedItemId(ref.id.value));
    if (item == null) return null;
    await MovieOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.movie, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.movie, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (ref.kind == CatalogMediaKind.music) {
    final item = await MusicOwnedRepository(database)
        .findById(MusicOwnedItemId(ref.id.value));
    if (item == null) return null;
    await MusicOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.music, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.music, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  if (ref.kind == CatalogMediaKind.tv) {
    final item =
        await TvOwnedRepository(database).findById(TvOwnedItemId(ref.id.value));
    if (item == null) return null;
    await TvOwnedRepository(database).markDeleted(item, deletedAt);
    final deleted = item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt);
    final serialized =
        collectarrTypedOwnedItemSyncPayload(CatalogMediaKind.tv, deleted);
    return OwnedItemMutationResult(
        ref: OwnedItemRef(
            kind: CatalogMediaKind.tv, id: OwnedItemId(deleted.id.value)),
        syncPayload: serialized.payload,
        isDeleted: true);
  }
  return null;
}

Future<OwnedItemCreatePayload?> collectarrOwnedCreatePayloadByRef(
    LocalDatabase database, OwnedItemRef ref) async {
  if (ref.kind == CatalogMediaKind.anime) {
    final item = await AnimeOwnedRepository(database)
        .findById(AnimeOwnedItemId(ref.id.value));
    if (item == null) return null;
    return AnimeOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (ref.kind == CatalogMediaKind.boardgame) {
    final item = await BoardGameOwnedRepository(database)
        .findById(BoardGameOwnedItemId(ref.id.value));
    if (item == null) return null;
    return BoardgameOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (ref.kind == CatalogMediaKind.book) {
    final item = await BookOwnedRepository(database)
        .findById(BookOwnedItemId(ref.id.value));
    if (item == null) return null;
    return BookOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (ref.kind == CatalogMediaKind.comic) {
    final item = await ComicOwnedRepository(database)
        .findById(ComicOwnedItemId(ref.id.value));
    if (item == null) return null;
    return ComicOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (ref.kind == CatalogMediaKind.game) {
    final item = await GameOwnedRepository(database)
        .findById(GameOwnedItemId(ref.id.value));
    if (item == null) return null;
    return GameOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (ref.kind == CatalogMediaKind.manga) {
    final item = await MangaOwnedRepository(database)
        .findById(MangaOwnedItemId(ref.id.value));
    if (item == null) return null;
    return MangaOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (ref.kind == CatalogMediaKind.movie) {
    final item = await MovieOwnedRepository(database)
        .findById(MovieOwnedItemId(ref.id.value));
    if (item == null) return null;
    return MovieOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (ref.kind == CatalogMediaKind.music) {
    final item = await MusicOwnedRepository(database)
        .findById(MusicOwnedItemId(ref.id.value));
    if (item == null) return null;
    return MusicOwnedItemCreatePayload.fromTypedItem(item);
  }
  if (ref.kind == CatalogMediaKind.tv) {
    final item =
        await TvOwnedRepository(database).findById(TvOwnedItemId(ref.id.value));
    if (item == null) return null;
    return TvOwnedItemCreatePayload.fromTypedItem(item);
  }
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

const List<CatalogKindTransportCodec<Object?>>
    collectarrKindCatalogTransportCodecs = [
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
