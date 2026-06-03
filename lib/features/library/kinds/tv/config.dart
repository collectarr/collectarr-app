import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/movie/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const tvWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.tv,
  title: 'TV',
  icon: Icons.tv_outlined,
  accent: Color(0xFF3D8DBF),
  preferencePrefix: 'tv',
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

const tvLibraryConfig = LibraryTypeConfig(
  workspace: tvWorkspaceConfig,
  singularLabel: 'TV Show',
  pluralLabel: 'TV Shows',
  defaultMetadataProvider: 'tmdb',
  metadataProviders: [
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  presentation: moviesLibraryMediaPresentation,
  editDialogBuilder: buildMovieLibraryEditDialog,
  addChrome: LibraryAddChromeConfig(
    videoKindFilterOptions: [
      LibraryAddVideoKindFilterOption(
        kind: 'tv',
        label: 'TV Shows',
        icon: Icons.tv_outlined,
      ),
    ],
    defaultVideoKindFilters: {'tv'},
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
    videoSeriesEntryTypes: {'tv'},
    videoShelfDrilldownEntryTypes: {'tv'},
  ),
);