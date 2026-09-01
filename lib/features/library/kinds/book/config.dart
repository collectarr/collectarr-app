import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_browser_delegate.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_dialog.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/book/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
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

final bookTransferableFields = <TransferableField>[
  TransferableField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.bookDetails?.signedBy,
    write: (item, value) {
      final b = item.bookDetails ?? const BookOwnedDetails();
      return item.copyWith(details: b.copyWith(signedBy: value));
    },
  ),
  TransferableField(
    key: 'dustJacketPresent',
    label: 'Dust jacket',
    icon: Icons.book_outlined,
    type: TransferableFieldType.boolean,
    scope: LibraryEditScope.release,
    read: (item) =>
        (item.bookDetails?.dustJacketPresent == true) ? 'true' : null,
    write: (item, value) {
      final b = item.bookDetails ?? const BookOwnedDetails();
      return item.copyWith(
          details: b.copyWith(dustJacketPresent: value == 'true'));
    },
  ),
  TransferableField(
    key: 'dustJacketCondition',
    label: 'Dust jacket condition',
    icon: Icons.grade_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEditScope.release,
    read: (item) => item.bookDetails?.dustJacketCondition,
    write: (item, value) {
      final b = item.bookDetails ?? const BookOwnedDetails();
      return item.copyWith(details: b.copyWith(dustJacketCondition: value));
    },
  ),
];

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
  editDialogBuilder: buildBookLibraryEditDialog,
  kindBrowserDelegateBuilder: buildReleaseFolderBrowserDelegate,
  inspectorSectionsBuilder: (_, __) => const [],
  capabilities: LibraryTypeCapabilities(
    showsSynopsis: true,
    showsCreatorSpotlight: true,
    canScanCover: true,
    contentHierarchy: LibraryContentHierarchy.volumes,
    supportsOwnedItemImages: false,
    supportsMediaReleaseSplit: true,
    supportsReadingQueue: true,
    supportsSeriesSubgroups: true,
    vocabulary: StandardKindVocabularyCapability(BookVocabularies.all),
    mediaScopeGroupIds: _bookMediaGroupModes,
    releaseScopeGroupIds: _bookReleaseGroupModes,
    mediaScopeSortIds: _bookMediaSortColumns,
    releaseScopeSortIds: _bookReleaseSortColumns,
  ),
  showsDefaultInspectorPersonalSection: false,
  conditions: BookVocabularies.condition.builtIns,
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
