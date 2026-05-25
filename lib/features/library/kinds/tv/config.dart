import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/shared/video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/shared/video_edit_support.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const tvWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.tv,
  title: 'TV Shows',
  icon: Icons.tv,
  preferencePrefix: 'tv',
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

const tvLibraryConfig = LibraryTypeConfig(
  workspace: tvWorkspaceConfig,
  singularLabel: 'TV show',
  pluralLabel: 'TV shows',
  defaultMetadataProvider: 'tmdb',
  metadataProviders: [
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  editDialogBuilder: buildVideoLibraryEditDialog,
  detailPageBuilder: buildVideoLibraryDetailPage,
  presentation: tvLibraryMediaPresentation,
  editPresentation: videoLibraryEditPresentation,
  inspectorSectionsBuilder: buildVideoInspectorSections,
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    contentHierarchy: LibraryContentHierarchy.seasons,
  ),
);