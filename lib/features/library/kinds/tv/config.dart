import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:collectarr_app/features/library/media/video/detail/video_detail_page.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'edit_presentation_builder.dart';

const tvWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.tv,
  title: 'TV',
  icon: Icons.tv_outlined,
  accent: Color(0xFF00A7A0),
  preferencePrefix: 'tv',
);

final tvLibraryConfig = LibraryTypeConfig(
  workspace: tvWorkspaceConfig,
  singularLabel: 'TV Show',
  pluralLabel: 'TV Shows',
  defaultMetadataProvider: 'tmdb',
  metadataProviders: [
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  presentation: tvLibraryMediaPresentation,
  editPresentation: tvLibraryEditPresentation,
  editDialogBuilder: buildTvLibraryEditDialog,
  detailPageBuilder: buildVideoLibraryDetailPage,
  inspectorSectionsBuilder: buildTvInspectorSections,
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
    releaseDateLabel: 'First aired',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Format / Edition',
    barcodeLabel: 'UPC / Barcode',
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    supportsMediaReleaseSplit: true,
    contentHierarchy: LibraryContentHierarchy.seasons,
    supportsSeriesSubgroups: true,
    wideDialog: true,
  ),
  workspaceBehavior: LibraryKindWorkspaceBehavior(
    showsSeasonGroupProgress: true,
    defaultVideoDisplayLevel: tvDefaultVideoDisplayLevel,
    defaultVideoGrouping: tvDefaultVideoGrouping,
    videoSeriesEntryTypes: {'tv'},
    videoShelfDrilldownEntryTypes: {'tv'},
  ),
  showsDefaultInspectorPersonalSection: false,
);