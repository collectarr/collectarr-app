import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/tv/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/tv/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/vocabulary/tv_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/detail/video_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
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

final tvTransferableFields = <TransferableField>[
  TransferableField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.tvDetails?.features,
    write: (item, value) {
      final d = item.tvDetails ?? const TvOwnedDetails();
      return item.copyWith(details: d.copyWith(features: value));
    },
  ),
  TransferableField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.tvDetails?.boxSetName,
    write: (item, value) {
      final d = item.tvDetails ?? const TvOwnedDetails();
      return item.copyWith(details: d.copyWith(boxSetName: value));
    },
  ),
  TransferableField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.tvDetails?.packaging,
    write: (item, value) {
      final d = item.tvDetails ?? const TvOwnedDetails();
      return item.copyWith(details: d.copyWith(packaging: value));
    },
  ),
];

final tvLibraryConfig = LibraryTypeConfig(
  workspace: tvWorkspaceConfig,
  singularLabel: 'TV Show',
  pluralLabel: 'TV Shows',
  defaultMetadataProvider: 'tmdb',
  metadataProviders: [
    tmdbMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  releaseCapability:
      const VideoReleaseProjectionCapability<LibraryWorkspaceDto>(),
  presentation: tvLibraryMediaPresentation,
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
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    supportsMediaReleaseSplit: true,
    contentHierarchy: LibraryContentHierarchy.seasons,
    wideDialog: true,
    vocabulary: StandardKindVocabularyCapability(TvVocabularies.all),
  ),
  showsDefaultInspectorPersonalSection: false,
);
