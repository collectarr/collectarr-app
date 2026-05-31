import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

const comicsWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.comic,
  title: 'Comics',
  icon: Icons.library_books,
  accent: kAppTopBar,
  preferencePrefix: 'comics',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.issue,
    LibraryTableColumn.variant,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.grade,
    LibraryTableColumn.condition,
    LibraryTableColumn.price,
    LibraryTableColumn.location,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const comicsLibraryConfig = LibraryTypeConfig(
  workspace: comicsWorkspaceConfig,
  singularLabel: 'Comic',
  pluralLabel: 'Comics',
  defaultMetadataProvider: 'gcd',
  metadataProviders: [
    gcdMetadataProvider,
    comicVineMetadataProvider,
    mangadexMetadataProvider,
    anilistMetadataProvider,
    hardcoverMetadataProvider,
  ],
  addDialogLauncher: showComicLibraryAddDialog,
  trackingProfile: comicTrackingProfile,
  editDialogBuilder: buildComicLibraryEditDialog,
  inspectorHeroBuilder: buildComicInspectorHero,
  inspectorSectionsBuilder: buildComicInspectorSections,
  presentation: comicsLibraryMediaPresentation,
  editPresentation: comicsLibraryEditPresentation,
  editChrome: LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    synopsisLabel: 'Plot',
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  mediaFields: MediaEditFields.print(
    numberLabel: 'No. / Vol.',
    publisherLabel: 'Publisher / Studio / Creator',
  ),
  collectionExportTitleLabel: 'Series',
  manualAddUsesTitleAsSeries: true,
  editUsesTitleAsSeries: true,
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    ...kComicTransferableFieldKeys,
  ],
  releaseFields: ReleaseEditFields(
    variantLabel: 'Edition / Variant / Format',
    barcodeLabel: 'Barcode / UPC / ISBN',
    variantSeedsPhysicalFormatLabel: true,
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    canScanCover: true,
  ),
  conditions: kComicConditions,
  grades: kComicGrades,
  defaultCondition: 'Near Mint',
  defaultGrade: 'Ungraded',
);