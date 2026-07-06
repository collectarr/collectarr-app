import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const boardGamesWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.boardgame,
  title: 'Board Games',
  icon: Icons.casino_outlined,
  accent: Color(0xFFE0A52B),
  preferencePrefix: 'boardgames',
  defaultSortColumn: LibrarySortColumn.title,
  availableSortColumns: boardGamesLibrarySortColumns,
  availableTableColumns: kAllLibraryTableColumns,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.location,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const boardGamesLibraryConfig = LibraryTypeConfig(
  workspace: boardGamesWorkspaceConfig,
  singularLabel: 'Board Game',
  pluralLabel: 'Board Games',
  defaultMetadataProvider: 'bgg',
  metadataProviders: [
    bggMetadataProvider,
  ],
  trackingProfile: gameTrackingProfile,
  editDialogBuilder: buildBoardGameLibraryEditDialog,
  inspectorSectionsBuilder: _emptyInspectorSectionsBuilder,
  editPresentation: boardGamesLibraryEditPresentation,
  kindBrowserDelegateBuilder: buildReleaseFolderBrowserDelegate,
  presentation: boardGamesLibraryMediaPresentation,
  mediaFields: MediaEditFields(
    numberLabel: 'Edition',
    publisherLabel: 'Publisher / Designer',
    releaseDateLabel: 'Release date',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Expansion / Edition',
    barcodeLabel: 'Barcode',
  ),
  capabilities: LibraryTypeCapabilities(
    canScanCover: true,
  ),
  showsDefaultInspectorPersonalSection: false,
);

List<Widget> _emptyInspectorSectionsBuilder(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    const [];
