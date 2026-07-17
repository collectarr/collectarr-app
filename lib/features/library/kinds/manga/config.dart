import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/manga/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_fields.dart';

const mangaWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.manga,
  title: 'Manga',
  icon: Icons.import_contacts_outlined,
  accent: Color(0xFFFF6F91),
  preferencePrefix: 'manga',
);

final mangaLibraryConfig = LibraryTypeConfig(
  workspace: mangaWorkspaceConfig,
  defaultSortColumn: 'title',
  defaultVisibleColumns: const {
    'status',
    'cover',
    'title',
    'publisher',
    'release_date',
    'country',
    'language',
    'age_rating',
    'wishlist',
    'updated',
  },
  availableSortColumns: const [
    'series',
    'publisher',
    'status',
    'title',
    'comic.issue',
    'story_arc',
    'variant',
    'format',
    'release_date',
    'barcode',
    'grade',
    'raw_or_slabbed',
    'grading_company',
    'condition',
    'price',
    'location',
    'collection_status',
    'wishlist',
    'comic.key_issue',
    'added',
    'updated',
  ],
  availableSortColumnDefinitions: mangaLibrarySortDefinitions,
  availableTableColumns: const [
    'status',
    'cover',
    'title',
    'publisher',
    'release_date',
    'country',
    'language',
    'age_rating',
    'wishlist',
    'updated',
  ],
  singularLabel: 'Manga',
  pluralLabel: 'Manga',
  defaultMetadataProvider: 'hardcover',
  metadataProviders: [
    hardcoverMetadataProvider,
    comicVineMetadataProvider,
    anilistMetadataProvider,
    mangadexMetadataProvider,
  ],
  trackingProfile: comicTrackingProfile,
  presentation: mangaLibraryMediaPresentation,
  editDialogBuilder: buildMangaLibraryEditDialog,
  inspectorSectionsBuilder: _emptyInspectorSectionsBuilder,
  editChrome: LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    synopsisLabel: 'Plot',
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  mediaFields: MediaEditFields.print(
    numberLabel: 'Chapter / Vol.',
    publisherLabel: 'Publisher / Studio / Creator',
    releaseDateLabel: 'First published',
  ),
  collectionExportTitleLabel: 'Series',
  manualAddUsesTitleAsSeries: true,
  editUsesTitleAsSeries: true,
  releaseFields: ReleaseEditFields(
    variantLabel: 'Edition / Variant / Format',
    barcodeLabel: 'Barcode / UPC / ISBN',
    variantSeedsPhysicalFormatLabel: true,
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    canScanCover: true,
    supportsMediaReleaseSplit: true,
    supportsIndexReassignment: true,
    contentHierarchy: LibraryContentHierarchy.volumes,
    supportsSeriesSubgroups: true,
  ),
  showsDefaultInspectorPersonalSection: false,
);

List<Widget> _emptyInspectorSectionsBuilder(
  BuildContext context,
  LibraryInspectorRequest request,
) =>
    const [];
