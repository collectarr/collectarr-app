import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
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
);

final Set<LibraryGroupIdRuntime> _bookMediaGroupModes = Set.unmodifiable({
  BookGroupIds.author,
  BookGroupIds.publisher,
  BookGroupIds.series,
  BookGroupIds.condition,
  BookGroupIds.location,
  BookGroupIds.rating,
});

final Set<LibraryGroupIdRuntime> _bookReleaseGroupModes = Set.unmodifiable({
  BookGroupIds.author,
  BookGroupIds.publisher,
  BookGroupIds.series,
  BookGroupIds.condition,
  BookGroupIds.location,
  BookGroupIds.rating,
});

final Set<LibrarySortIdRuntime> _bookMediaSortColumns = Set.unmodifiable({
  BookSortIds.status,
  BookSortIds.title,
  BookSortIds.author,
  BookSortIds.publisher,
  BookSortIds.releaseDate,
  BookSortIds.pageCount,
  BookSortIds.series,
  BookSortIds.rating,
  BookSortIds.pricePaid,
  BookSortIds.updatedAt,
});

final Set<LibrarySortIdRuntime> _bookReleaseSortColumns = Set.unmodifiable({
  BookSortIds.status,
  BookSortIds.title,
  BookSortIds.author,
  BookSortIds.publisher,
  BookSortIds.releaseDate,
  BookSortIds.pageCount,
  BookSortIds.series,
  BookSortIds.rating,
  BookSortIds.pricePaid,
  BookSortIds.updatedAt,
});
