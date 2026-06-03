import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const animeWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.anime,
  title: 'Anime',
  icon: Icons.movie_filter_outlined,
  accent: Color(0xFFC94DFF),
  preferencePrefix: 'anime',
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

const animeLibraryConfig = LibraryTypeConfig(
  workspace: animeWorkspaceConfig,
  singularLabel: 'Anime',
  pluralLabel: 'Anime',
  defaultMetadataProvider: 'anilist',
  metadataProviders: [
    anilistMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  presentation: moviesLibraryMediaPresentation,
  editDialogBuilder: buildMovieLibraryEditDialog,
  addChrome: LibraryAddChromeConfig(
    videoKindFilterOptions: [
      LibraryAddVideoKindFilterOption(
        kind: 'anime',
        label: 'Anime',
        icon: Icons.auto_awesome_outlined,
      ),
    ],
    defaultVideoKindFilters: {'anime'},
  ),
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
    wideDialog: true,
    videoSeriesEntryTypes: {'anime'},
    videoShelfDrilldownEntryTypes: {'anime'},
  ),
);