import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
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
  presentation: moviesLibraryMediaPresentation,
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
);

final Set<LibraryGroupIdRuntime> _movieMediaGroupModes = Set.unmodifiable({
  MovieGroupIds.director,
  MovieGroupIds.publisher,
  MovieGroupIds.genre,
  MovieGroupIds.releaseYear,
  MovieGroupIds.audienceRating,
  MovieGroupIds.movieOrTvSeries,
  MovieGroupIds.location,
});

final Set<LibraryGroupIdRuntime> _movieEditionGroupModes = Set.unmodifiable({
  MovieGroupIds.format,
  MovieGroupIds.audioTracks,
  MovieGroupIds.editionReleaseDate,
  MovieGroupIds.location,
});

final Set<LibrarySortIdRuntime> _movieMediaSortColumns = Set.unmodifiable({
  MovieSortIds.status,
  MovieSortIds.title,
  MovieSortIds.publisher,
  MovieSortIds.releaseDate,
});

final Set<LibrarySortIdRuntime> _movieEditionSortColumns = Set.unmodifiable({
  MovieSortIds.status,
  MovieSortIds.title,
  MovieSortIds.publisher,
  MovieSortIds.releaseDate,
});
