import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_workspace_behavior.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';

const musicWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.music,
  title: 'Music',
  icon: Icons.music_note,
  accent: Color(0xFFFDAD49),
  preferencePrefix: 'music',
);

final musicLibraryConfig = LibraryTypeConfig(
  workspace: musicWorkspaceConfig,
  defaultSortColumn: 'title',
  defaultVisibleColumns: const {
    'status',
    'cover',
    'artist',
    'album',
    'title',
    'label',
    'catalog_number',
    'format',
    'disc_count',
    'track_count',
    'track_length',
    'vinyl_color',
    'rpm',
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
  availableSortColumnDefinitions: musicLibrarySortDefinitions,
  availableTableColumns: const [
    'status',
    'cover',
    'artist',
    'album',
    'title',
    'label',
    'catalog_number',
    'format',
    'disc_count',
    'track_count',
    'track_length',
    'vinyl_color',
    'rpm',
    'release_date',
    'barcode',
    'condition',
    'location',
    'wishlist',
    'updated',
  ],
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
  ),
  workspaceBehavior: const LibraryKindWorkspaceBehavior(
    supportsTrackSearch: true,
    usesTrackListCard: true,
  ),
);

List<Widget> _emptyInspectorSectionsBuilder(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    const [];
