import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/game/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/game/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/game/inspector_panel.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_fields.dart';

const gamesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.game,
  title: 'Games',
  icon: Icons.sports_esports,
  accent: Color(0xFFF64458),
  preferencePrefix: 'games',
);

final gamesLibraryConfig = LibraryTypeConfig(
  workspace: gamesWorkspaceConfig,
  defaultSortColumn: 'title',
  defaultVisibleColumns: const {
    'status',
    'cover',
    'title',
    'publisher',
    'release_date',
    'barcode',
    'condition',
    'location',
    'wishlist',
    'updated',
  },
  availableSortColumns: const [
    'series',
    'publisher',
    'status',
    'title',
    'issue',
    'story_arc',
    'variant',
    'format',
    'release_date',
    'barcode',
    'grade',
    'condition',
    'price',
    'location',
    'collection_status',
    'wishlist',
    'added',
    'updated',
    'country',
    'language',
    'page_count',
    'age_rating',
    'imprint',
  ],
  availableSortColumnDefinitions: gameLibrarySortDefinitions,
  availableTableColumns: const [
    'status',
    'cover',
    'title',
    'publisher',
    'release_date',
    'barcode',
    'condition',
    'location',
    'wishlist',
    'updated',
  ],
  singularLabel: 'Game',
  pluralLabel: 'Games',
  defaultMetadataProvider: 'igdb',
  metadataProviders: [
    igdbMetadataProvider,
  ],
  trackingProfile: gameTrackingProfile,
  editDialogBuilder: buildGameLibraryEditDialog,
  editPresentation: gameLibraryEditPresentation,
  inspectorSectionsBuilder: buildGameInspectorSections,
  kindBrowserDelegateBuilder: buildReleaseFolderBrowserDelegate,
  presentation: gamesLibraryMediaPresentation,
  mediaFields: MediaEditFields(
    numberLabel: 'Version',
    publisherLabel: 'Publisher / Studio',
    releaseDateLabel: 'Release date',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Platform / Edition',
    barcodeLabel: 'UPC / Barcode',
  ),
  capabilities: LibraryTypeCapabilities(
    canScanCover: true,
    supportsMediaReleaseSplit: true,
  ),
  showsDefaultInspectorPersonalSection: false,
);
