import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/shared/edit_presentation_support.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

const booksWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.book,
  title: 'Books',
  icon: Icons.menu_book_outlined,
  preferencePrefix: 'books',
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
    LibraryTableColumn.location,
    LibraryTableColumn.wishlist,
    LibraryTableColumn.updated,
  },
);

const booksLibraryConfig = LibraryTypeConfig(
  workspace: booksWorkspaceConfig,
  singularLabel: 'Book',
  pluralLabel: 'Books',
  defaultMetadataProvider: 'openlibrary',
  metadataProviders: [
    openLibraryMetadataProvider,
    hardcoverMetadataProvider,
  ],
  trackingProfile: readingTrackingProfile,
  presentation: booksLibraryMediaPresentation,
  editPresentation: booksLibraryEditPresentation,
  editDialogBuilder: buildBookLibraryEditDialog,
  mediaFields: MediaEditFields.print(
    numberLabel: 'Volume',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Edition / Binding',
    barcodeLabel: 'ISBN / Barcode',
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    showsCreatorSpotlight: true,
    contentHierarchy: LibraryContentHierarchy.volumes,
    supportsOwnedItemImages: false,
  ),
  conditions: kBookConditions,
);