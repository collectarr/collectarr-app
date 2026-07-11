import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit_dialog.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/media/video/detail/video_detail_page.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_fields.dart';

const moviesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.movie,
  title: 'Movies',
  icon: Icons.movie_outlined,
  accent: Color(0xFF42AA55),
  preferencePrefix: 'movies',
);

final moviesLibraryConfig = LibraryTypeConfig(
  workspace: moviesWorkspaceConfig,
  defaultSortColumn: 'title',
  defaultVisibleColumns: moviesLibraryDefaultVisibleColumns,
  availableSortColumns: moviesLibrarySortColumns,
  availableSortColumnDefinitions: movieLibrarySortDefinitions,
  availableTableColumns: moviesLibraryTableColumns,
  singularLabel: 'Movie',
  pluralLabel: 'Movies',
  defaultMetadataProvider: 'tmdb',
  metadataProviders: [
    tmdbMetadataProvider,
  ],
  addDialogLauncher: showMovieLibraryAddDialog,
  trackingProfile: videoTrackingProfile,
  editDialogBuilder: buildMovieLibraryEditDialog,
  detailPageBuilder: buildVideoLibraryDetailPage,
  presentation: moviesLibraryMediaPresentation,
  kindBrowserDelegateBuilder: buildMovieBrowserDelegate,
  addChrome: LibraryAddChromeConfig(
    videoKindFilterOptions: [
      LibraryAddVideoKindFilterOption(
        kind: 'movie',
        label: 'Movies',
        icon: Icons.movie_outlined,
      ),
      LibraryAddVideoKindFilterOption(
        kind: 'collection',
        label: 'Box Sets',
        icon: Icons.collections_bookmark_outlined,
      ),
    ],
    defaultVideoKindFilters: {'movie'},
  ),
  editPresentation: movieLibraryEditPresentation,
  inspectorSectionsBuilder: buildMovieInspectorSections,
  mediaFields: MediaEditFields(
    numberLabel: 'Edition no.',
    publisherLabel: 'Studio',
    releaseDateLabel: 'Release Date',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Format / Edition',
    barcodeLabel: 'UPC / Barcode',
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    canScanCover: true,
    supportsMediaReleaseSplit: true,
    wideDialog: true,
    mediaScopeGroupModes: _movieMediaGroupModes,
    releaseScopeGroupModes: _movieEditionGroupModes,
    mediaScopeSortColumns: _movieMediaSortColumns,
    releaseScopeSortColumns: _movieEditionSortColumns,
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    defaultVideoDisplayLevel: VideoDisplayLevel.titleWork,
    defaultVideoGrouping: VideoGroupingDefault.none,
    videoSeriesEntryTypes: {'tv'},
    videoShelfDrilldownEntryTypes: {'movie', 'tv', 'anime'},
  ),
  showsDefaultInspectorPersonalSection: false,
);

const Set<String> _movieMediaGroupModes = {
  'title',
  'movie_or_tv_series',
  'genre',
  'publisher',
  'release_date',
  'release_month',
  'release_year',
  'country',
  'language',
  'age_rating',
  'audience_rating',
  'actor',
  'director',
  'producer',
  'writer',
  'photography',
  'musician',
  'collection_status',
  'condition',
  'location',
  'added_date',
  'added_month',
  'added_year',
  'modified_date',
  'modified_month',
  'watch_date',
  'watch_month',
  'watch_year',
};

const Set<String> _movieEditionGroupModes = {
  'title',
  'edition',
  'edition_release_date',
  'edition_release_month',
  'edition_release_year',
  'format',
  'box_set',
  'distributor',
  'hdr',
  'layers',
  'packaging',
  'regions',
  'screen_ratios',
  'subtitles',
  'audio_tracks',
  'extras',
  'collection_status',
  'condition',
  'location',
  'added_date',
  'added_month',
  'added_year',
  'modified_date',
  'modified_month',
  'watch_date',
  'watch_month',
  'watch_year',
};

const Set<String> _movieMediaSortColumns = {
  'status',
  'title',
  'publisher',
  'release_date',
  'country',
  'language',
  'age_rating',
  'condition',
  'price',
  'location',
  'collection_status',
  'wishlist',
  'added',
  'updated',
};

const Set<String> _movieEditionSortColumns = {
  'status',
  'title',
  'variant',
  'format',
  'publisher',
  'release_date',
  'barcode',
  'condition',
  'price',
  'location',
  'collection_status',
  'wishlist',
  'added',
  'updated',
};