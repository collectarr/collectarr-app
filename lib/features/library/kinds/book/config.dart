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
import 'package:collectarr_app/features/library/kinds/book/workspace/book_fields.dart';

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
    mediaScopeGroupIds: _bookMediaGroupModes,
    releaseScopeGroupIds: _bookReleaseGroupModes,
    mediaScopeSortIds: _bookMediaSortColumns,
    releaseScopeSortIds: _bookReleaseSortColumns,
  ),
  showsDefaultInspectorPersonalSection: false,
  conditions: kBookConditions,
);

const Set<String> _bookMediaGroupModes = {
  'creator',
  'country',
  'language',
  'release_date',
  'release_month',
  'publication_place',
  'release_year',
  'publisher',
  'series',
  'genre',
  'subject',
  'collection_status',
  'condition',
  'location',
  'added_date',
  'added_month',
  'added_year',
  'modified_date',
  'modified_month',
  'my_rating',
  'owner',
  'reader',
  'reading_status',
  'tags',
};

const Set<String> _bookReleaseGroupModes = {
  'audiobook_abridged',
  'box_set',
  'edition',
  'extras',
  'first_edition',
  'format',
  'narrator',
  'original_country',
  'original_language',
  'original_publication_date',
  'original_publication_month',
  'original_publication_place',
  'original_publication_year',
  'original_publisher',
  'paper_type',
  'printed_by',
  'cover_artist',
  'editor',
  'foreword_author',
  'ghost_writer',
  'illustrator',
  'photography',
  'translator',
  'collection_status',
  'condition',
  'location',
  'added_date',
  'added_month',
  'added_year',
  'modified_date',
  'modified_month',
  'my_rating',
  'owner',
  'reader',
  'reading_status',
  'tags',
};

const Set<String> _bookMediaSortColumns = {
  'status',
  'title',
  'series',
  'publisher',
  'release_date',
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
};

const Set<String> _bookReleaseSortColumns = {
  'status',
  'title',
  'variant',
  'format',
  'publisher',
  'release_date',
  'barcode',
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
};
