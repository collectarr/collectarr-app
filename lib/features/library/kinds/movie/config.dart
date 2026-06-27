import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit_dialog.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/video/video_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/kinds/video/video_detail_page.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const moviesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.movie,
  title: 'Movies',
  icon: Icons.movie_outlined,
  accent: Color(0xFF42AA55),
  preferencePrefix: 'movies',
  defaultSortColumn: LibrarySortColumn.title,
  availableSortColumns: kPlannedLibrarySortColumns,
  availableTableColumns: kAllLibraryTableColumns,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.country,
    LibraryTableColumn.language,
    LibraryTableColumn.ageRating,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const moviesLibraryConfig = LibraryTypeConfig(
  workspace: moviesWorkspaceConfig,
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
  inspectorPanelBuilder: buildVideoInspectorPanel,
  inspectorSectionsBuilder: buildVideoInspectorSections,
  mediaFields: MediaEditFields(
    numberLabel: 'Edition no.',
    publisherLabel: 'Studio',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Format / Edition',
    barcodeLabel: 'UPC / Barcode',
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    supportsVideoKindFilters: true,
    supportsMediaReleaseSplit: true,
    wideDialog: true,
    videoSeriesEntryTypes: {'tv'},
    videoShelfDrilldownEntryTypes: {'movie', 'tv', 'anime'},
    mediaScopeGroupModes: _movieMediaGroupModes,
    releaseScopeGroupModes: _movieEditionGroupModes,
    mediaScopeSortColumns: _movieMediaSortColumns,
    releaseScopeSortColumns: _movieEditionSortColumns,
  ),
  showsDefaultInspectorPersonalSection: false,
);

const Set<LibraryGroupMode> _movieMediaGroupModes = {
  LibraryGroupMode.title,
  LibraryGroupMode.movieOrTvSeries,
  LibraryGroupMode.genre,
  LibraryGroupMode.publisher,
  LibraryGroupMode.releaseDate,
  LibraryGroupMode.releaseMonth,
  LibraryGroupMode.releaseYear,
  LibraryGroupMode.country,
  LibraryGroupMode.language,
  LibraryGroupMode.ageRating,
  LibraryGroupMode.audienceRating,
  LibraryGroupMode.actor,
  LibraryGroupMode.director,
  LibraryGroupMode.producer,
  LibraryGroupMode.writer,
  LibraryGroupMode.photography,
  LibraryGroupMode.musician,
  LibraryGroupMode.collectionStatus,
  LibraryGroupMode.condition,
  LibraryGroupMode.location,
  LibraryGroupMode.addedDate,
  LibraryGroupMode.addedMonth,
  LibraryGroupMode.addedYear,
  LibraryGroupMode.modifiedDate,
  LibraryGroupMode.modifiedMonth,
  LibraryGroupMode.watchDate,
  LibraryGroupMode.watchMonth,
  LibraryGroupMode.watchYear,
};

const Set<LibraryGroupMode> _movieEditionGroupModes = {
  LibraryGroupMode.title,
  LibraryGroupMode.edition,
  LibraryGroupMode.editionReleaseDate,
  LibraryGroupMode.editionReleaseMonth,
  LibraryGroupMode.editionReleaseYear,
  LibraryGroupMode.format,
  LibraryGroupMode.boxSet,
  LibraryGroupMode.distributor,
  LibraryGroupMode.hdr,
  LibraryGroupMode.layers,
  LibraryGroupMode.packaging,
  LibraryGroupMode.regions,
  LibraryGroupMode.screenRatios,
  LibraryGroupMode.subtitles,
  LibraryGroupMode.audioTracks,
  LibraryGroupMode.extras,
  LibraryGroupMode.collectionStatus,
  LibraryGroupMode.condition,
  LibraryGroupMode.location,
  LibraryGroupMode.addedDate,
  LibraryGroupMode.addedMonth,
  LibraryGroupMode.addedYear,
  LibraryGroupMode.modifiedDate,
  LibraryGroupMode.modifiedMonth,
  LibraryGroupMode.watchDate,
  LibraryGroupMode.watchMonth,
  LibraryGroupMode.watchYear,
};

const Set<LibrarySortColumn> _movieMediaSortColumns = {
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.publisher,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.condition,
  LibrarySortColumn.price,
  LibrarySortColumn.location,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.wishlist,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
};

const Set<LibrarySortColumn> _movieEditionSortColumns = {
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.variant,
  LibrarySortColumn.format,
  LibrarySortColumn.publisher,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.barcode,
  LibrarySortColumn.condition,
  LibrarySortColumn.price,
  LibrarySortColumn.location,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.wishlist,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
};