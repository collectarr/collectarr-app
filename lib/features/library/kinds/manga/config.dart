import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/shared/edit_presentation_support.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const mangaWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.manga,
  title: 'Manga',
  icon: Icons.menu_book,
  preferencePrefix: 'manga',
  defaultSortColumn: LibrarySortColumn.title,
  defaultVisibleColumns: {
    LibraryTableColumn.status,
    LibraryTableColumn.cover,
    LibraryTableColumn.title,
    LibraryTableColumn.issue,
    LibraryTableColumn.publisher,
    LibraryTableColumn.releaseDate,
    LibraryTableColumn.barcode,
    LibraryTableColumn.updated,
  },
);

const mangaLibraryConfig = LibraryTypeConfig(
  workspace: mangaWorkspaceConfig,
  singularLabel: 'Manga',
  pluralLabel: 'Manga',
  defaultMetadataProvider: 'anilist',
  metadataProviders: [
    mangadexMetadataProvider,
    anilistMetadataProvider,
    hardcoverMetadataProvider,
  ],
  addDialogLauncher: showComicLibraryAddDialog,
  trackingProfile: comicTrackingProfile,
  editPresentation: comicsLibraryEditPresentation,
  presentation: comicsLibraryMediaPresentation,
  mediaFields: MediaEditFields.print(
    numberLabel: 'No. / Vol.',
    publisherLabel: 'Publisher / Studio / Creator',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Edition / Variant / Format',
    barcodeLabel: 'Barcode / UPC / ISBN',
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    canScanCover: true,
  ),
);
