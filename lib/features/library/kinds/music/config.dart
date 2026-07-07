import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const musicWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.music,
  title: 'Music',
  icon: Icons.music_note,
  accent: Color(0xFFFDAD49),
  preferencePrefix: 'music',
  defaultSortColumn: LibrarySortColumn.title,
  availableSortColumns: kPlannedLibrarySortColumns,
  availableTableColumns: kAllLibraryTableColumns,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.artist,
    LibraryTableColumn.album,
    LibraryTableColumn.title,
    LibraryTableColumn.label,
    LibraryTableColumn.catalogNumber,
    LibraryTableColumn.format,
    LibraryTableColumn.discCount,
    LibraryTableColumn.trackCount,
    LibraryTableColumn.length,
    LibraryTableColumn.vinylColor,
    LibraryTableColumn.rpm,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.condition,
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
  inspectorSectionsBuilder: _emptyInspectorSectionsBuilder,
  showsDefaultInspectorPersonalSection: false,
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
    publisherLabel: 'Label',
    releaseDateLabel: 'Original release date',
  ),
  collectionExportTitleLabel: 'Release',
  releaseFields: ReleaseEditFields(
    variantLabel: 'Format / Edition',
    barcodeLabel: 'Barcode / Catalog no.',
  ),
  capabilities: LibraryTypeCapabilities(
    showsTrackData: true,
    supportsMediaReleaseSplit: true,
    supportsMetadataCompare: true,
    prefersSquareCovers: true,
    usesTrackListCard: true,
  ),
);

List<Widget> _emptyInspectorSectionsBuilder(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    const [];
