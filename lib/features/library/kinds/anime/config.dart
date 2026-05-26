import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/shared/video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/shared/video_edit_support.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const animeWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.anime,
  title: 'Anime',
  icon: Icons.movie_filter_outlined,
  preferencePrefix: 'anime',
  defaultSortColumn: LibrarySortColumn.title,
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
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  editDialogBuilder: buildVideoLibraryEditDialog,
  detailPageBuilder: buildVideoLibraryDetailPage,
  presentation: animeLibraryMediaPresentation,
  editPresentation: videoLibraryEditPresentation,
  inspectorSectionsBuilder: buildVideoInspectorSections,
  mediaFields: MediaEditFields(
    numberLabel: 'Season / Volume',
    publisherLabel: 'Studio / Publisher',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Edition / Format',
    barcodeLabel: 'UPC / Barcode',
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    contentHierarchy: LibraryContentHierarchy.seasons,
  ),
);