import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_release_projection_capability.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const animeWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.anime,
  title: 'Anime',
  icon: Icons.movie_filter_outlined,
  accent: Color(0xFFC94DFF),
  preferencePrefix: 'anime',
);

final animeTransferableFields = <TransferableField>[
  TransferableField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.animeDetails?.features,
    write: (item, value) {
      final d = item.animeDetails ?? const AnimeOwnedDetails();
      return item.copyWith(details: d.copyWith(features: value));
    },
  ),
  TransferableField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.animeDetails?.boxSetName,
    write: (item, value) {
      final d = item.animeDetails ?? const AnimeOwnedDetails();
      return item.copyWith(details: d.copyWith(boxSetName: value));
    },
  ),
  TransferableField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.animeDetails?.packaging,
    write: (item, value) {
      final d = item.animeDetails ?? const AnimeOwnedDetails();
      return item.copyWith(details: d.copyWith(packaging: value));
    },
  ),
];

final animeLibraryConfig = LibraryTypeConfig(
  workspace: animeWorkspaceConfig,
  singularLabel: 'Anime',
  pluralLabel: 'Anime',
  defaultMetadataProvider: 'anilist',
  metadataProviders: [
    anilistMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
  releaseCapability:
      const VideoReleaseProjectionCapability<LibraryWorkspaceDto>(),
  presentation: animeLibraryMediaPresentation,
  editDialogBuilder: buildAnimeLibraryEditDialog,
  inspectorSectionsBuilder: _emptyInspectorSectionsBuilder,
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
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    supportsMediaReleaseSplit: true,
    wideDialog: true,
  ),
  showsDefaultInspectorPersonalSection: false,
);

List<Widget> _emptyInspectorSectionsBuilder(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    const [];
