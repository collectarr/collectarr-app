import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/anime/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_fields.dart';

const animeWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.anime,
  title: 'Anime',
  icon: Icons.movie_filter_outlined,
  accent: Color(0xFFC94DFF),
  preferencePrefix: 'anime',
);

final animeLibraryConfig = LibraryTypeConfig(
  workspace: animeWorkspaceConfig,
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: animeLibraryDefaultVisibleColumns,
  availableSortColumns: animeLibrarySortColumns,
  availableSortColumnDefinitions: animeLibrarySortColumnDefinitions,
  availableTableColumns: animeLibraryTableColumns,
  singularLabel: 'Anime',
  pluralLabel: 'Anime',
  defaultMetadataProvider: 'anilist',
  metadataProviders: [
    anilistMetadataProvider,
  ],
  trackingProfile: videoTrackingProfile,
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
    wideDialog: true,
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    supportsSeriesIssueJump: true,
    defaultVideoDisplayLevel: VideoDisplayLevel.season,
    defaultVideoGrouping: VideoGroupingDefault.bySeries,
    videoSeriesEntryTypes: {'anime'},
    videoShelfDrilldownEntryTypes: {'anime'},
  ),
  showsDefaultInspectorPersonalSection: false,
);

List<Widget> _emptyInspectorSectionsBuilder(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    const [];