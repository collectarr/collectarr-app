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
  preferencePrefix: 'music',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.storageBox,
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
  mediaFields: MediaEditFields(
    numberLabel: 'Disc / Volume',
    publisherLabel: 'Label / Artist',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Format / Edition',
    barcodeLabel: 'Barcode / Catalog no.',
  ),
  capabilities: LibraryTypeCapabilities(
    showsTrackData: true,
  ),
);