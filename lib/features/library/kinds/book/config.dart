import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_dialog.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

const booksWorkspaceConfig = LibraryWorkspaceConfig(
  kind: CatalogMediaKind.book,
  title: 'Books',
  icon: Icons.menu_book_outlined,
  accent: Color(0xFFBB72B6),
  preferencePrefix: 'books',
);

final booksLibraryConfig = LibraryTypeConfig(
  workspace: booksWorkspaceConfig,
  singularLabel: 'Book',
  pluralLabel: 'Books',
  defaultMetadataProvider: 'openlibrary',
  metadataProviders: [
    openLibraryMetadataProvider,
    hardcoverMetadataProvider,
  ],
  trackingProfile: readingTrackingProfile,
  presentation: bookLibraryMediaPresentation,
  editPresentation: LibraryEditPresentation(
    builder: BookLibraryMediaEditPresentationBuilder(),
    mediaBuilder: BookLibraryMediaEditPresentationBuilder(),
    releaseBuilder: BookLibraryReleaseEditPresentationBuilder(),
  ),
  editDialogBuilder: buildBookLibraryEditDialog,
  kindBrowserDelegateBuilder: buildReleaseFolderBrowserDelegate,
  inspectorSectionsBuilder: (_, __) => const [],
  mediaFields: MediaEditFields.print(
    numberLabel: 'Volume',
    publisherLabel: 'Publisher',
    releaseDateLabel: 'First published',
  ),
  releaseFields: ReleaseEditFields(
    variantLabel: 'Edition / Binding',
    barcodeLabel: 'ISBN / Barcode',
  ),
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    showsCreatorSpotlight: true,
    canScanCover: true,
    contentHierarchy: LibraryContentHierarchy.volumes,
    supportsOwnedItemImages: false,
    supportsMediaReleaseSplit: true,
    supportsReadingQueue: true,
    supportsSeriesSubgroups: true,
    mediaScopeGroupIds: _bookMediaGroupModes,
    releaseScopeGroupIds: _bookReleaseGroupModes,
    mediaScopeSortIds: _bookMediaSortColumns,
    releaseScopeSortIds: _bookReleaseSortColumns,
  ),
  showsDefaultInspectorPersonalSection: false,
  conditions: kBookConditions,
);

const Set<String> _bookMediaGroupModes = {
  'book.author',
  'book.publisher',
  'book.series',
  'book.condition',
  'book.location',
  'book.rating',
};

const Set<String> _bookReleaseGroupModes = {
  'book.author',
  'book.publisher',
  'book.series',
  'book.condition',
  'book.location',
  'book.rating',
};

const Set<String> _bookMediaSortColumns = {
  'book.status',
  'book.title',
  'book.author',
  'book.publisher',
  'book.release_date',
  'book.page_count',
  'book.series',
  'book.rating',
  'book.price_paid',
  'book.updated_at',
};

const Set<String> _bookReleaseSortColumns = {
  'book.status',
  'book.title',
  'book.author',
  'book.publisher',
  'book.release_date',
  'book.page_count',
  'book.series',
  'book.rating',
  'book.price_paid',
  'book.updated_at',
};
