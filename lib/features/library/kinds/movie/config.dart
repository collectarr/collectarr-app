import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit_dialog.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/detail/video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const moviesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.movie,
  title: 'Movies',
  icon: Icons.movie_outlined,
  accent: Color(0xFF42AA55),
  preferencePrefix: 'movies',
);

final movieTransferableFields = <TransferableField>[
  TransferableField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.movieDetails?.features,
    write: (item, value) {
      final d = item.movieDetails ?? const MovieOwnedDetails();
      return item.copyWith(details: d.copyWith(features: value));
    },
  ),
  TransferableField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.movieDetails?.boxSetName,
    write: (item, value) {
      final d = item.movieDetails ?? const MovieOwnedDetails();
      return item.copyWith(details: d.copyWith(boxSetName: value));
    },
  ),
  TransferableField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.movieDetails?.packaging,
    write: (item, value) {
      final d = item.movieDetails ?? const MovieOwnedDetails();
      return item.copyWith(details: d.copyWith(packaging: value));
    },
  ),
];

final moviesLibraryConfig = LibraryTypeConfig(
  workspace: moviesWorkspaceConfig,
  singularLabel: 'Movie',
  pluralLabel: 'Movies',
  defaultMetadataProvider: 'tmdb',
  metadataProviders: [
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  releaseCapability:
      const VideoReleaseProjectionCapability<LibraryWorkspaceDto>(),
  addDialogLauncher: showMovieLibraryAddDialog,
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
  inspectorSectionsBuilder: buildMovieInspectorSections,
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    canScanCover: true,
    supportsMediaReleaseSplit: true,
    wideDialog: true,
    mediaScopeGroupIds: _movieMediaGroupModes,
    releaseScopeGroupIds: _movieEditionGroupModes,
    mediaScopeSortIds: _movieMediaSortColumns,
    releaseScopeSortIds: _movieEditionSortColumns,
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
