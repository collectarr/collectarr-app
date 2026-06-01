import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/kinds/shared/edit_presentation_support.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const musicWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.music,
  title: 'Music',
  icon: Icons.music_note,
  accent: Color(0xFFE07A2D),
  preferencePrefix: 'music',
  defaultSortColumn: LibrarySortColumn.title,
  availableSortColumns: kPlannedLibrarySortColumns,
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

const musicLibraryConfig = LibraryTypeConfig(
  workspace: musicWorkspaceConfig,
  singularLabel: 'Music',
  pluralLabel: 'Music',
  defaultMetadataProvider: 'musicbrainz',
  metadataProviders: [
    musicBrainzMetadataProvider,
  ],
  trackingProfile: listeningTrackingProfile,
  editDialogBuilder: buildMusicLibraryEditDialog,
  presentation: musicLibraryMediaPresentation,
  editPresentation: musicLibraryEditPresentation,
  addChrome: LibraryAddChromeConfig(
    mediaReferenceLabel: 'Album',
    trackScopeSummary:
        'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.',
    mediaReferenceHelperLabel: 'Track or save the album itself.',
    editionReferenceHelperLabel:
        'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.',
  ),
  mediaFields: MediaEditFields(
    numberLabel: 'Disc / Volume',
    publisherLabel: 'Label / Artist',
  ),
  collectionExportTitleLabel: 'Release',
  releaseFields: ReleaseEditFields(
    variantLabel: 'Format / Edition',
    barcodeLabel: 'Barcode / Catalog no.',
  ),
  capabilities: LibraryTypeCapabilities(
    showsTrackData: true,
  ),
);