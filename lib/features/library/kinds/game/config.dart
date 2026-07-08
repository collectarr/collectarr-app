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

const gamesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.game,
  title: 'Games',
  icon: Icons.sports_esports,
  accent: Color(0xFFF64458),
  preferencePrefix: 'games',
  defaultSortColumn: LibrarySortColumn.title,
  availableSortColumns: kPlannedLibrarySortColumns,
  availableTableColumns: kAllLibraryTableColumns,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.platform,
    LibraryTableColumn.developer,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releasePlatform,
    LibraryTableColumn.ageRating,
    LibraryTableColumn.completion,
    LibraryTableColumn.condition,
    LibraryTableColumn.value,
    LibraryTableColumn.location,
    LibraryTableColumn.updated,
  },
);

final gamesLibraryConfig = LibraryTypeConfig(
  workspace: gamesWorkspaceConfig,
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
