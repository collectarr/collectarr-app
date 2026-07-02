import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/book/inspector_panel.dart';
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
  defaultSortColumn: LibrarySortColumn.title,
  availableSortColumns: kPlannedLibrarySortColumns,
  availableTableColumns: kAllLibraryTableColumns,
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
  editPresentation: LibraryEditPresentation(
    builder: BookLibraryMediaEditPresentationBuilder(),
    mediaBuilder: BookLibraryMediaEditPresentationBuilder(),
    releaseBuilder: BookLibraryReleaseEditPresentationBuilder(),
  ),
  editDialogBuilder: buildBookLibraryEditDialog,
  inspectorPanelBuilder: buildBookInspectorPanel,
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
    supportsMediaReleaseSplit: true,
    supportsReadingQueue: true,
    mediaScopeGroupModes: _bookMediaGroupModes,
    releaseScopeGroupModes: _bookReleaseGroupModes,
    mediaScopeSortColumns: _bookMediaSortColumns,
    releaseScopeSortColumns: _bookReleaseSortColumns,
  ),
  showsDefaultInspectorPersonalSection: false,
  conditions: kBookConditions,
);

const Set<LibraryGroupMode> _bookMediaGroupModes = {
  LibraryGroupMode.creator,
  LibraryGroupMode.country,
  LibraryGroupMode.language,
  LibraryGroupMode.releaseDate,
  LibraryGroupMode.releaseMonth,
  LibraryGroupMode.publicationPlace,
  LibraryGroupMode.releaseYear,
  LibraryGroupMode.publisher,
  LibraryGroupMode.series,
  LibraryGroupMode.genre,
  LibraryGroupMode.subject,
  LibraryGroupMode.collectionStatus,
  LibraryGroupMode.condition,
  LibraryGroupMode.location,
  LibraryGroupMode.addedDate,
  LibraryGroupMode.addedMonth,
  LibraryGroupMode.addedYear,
  LibraryGroupMode.modifiedDate,
  LibraryGroupMode.modifiedMonth,
  LibraryGroupMode.myRating,
  LibraryGroupMode.owner,
  LibraryGroupMode.reader,
  LibraryGroupMode.readingStatus,
  LibraryGroupMode.tags,
};

const Set<LibraryGroupMode> _bookReleaseGroupModes = {
  LibraryGroupMode.audiobookAbridged,
  LibraryGroupMode.boxSet,
  LibraryGroupMode.edition,
  LibraryGroupMode.extras,
  LibraryGroupMode.firstEdition,
  LibraryGroupMode.format,
  LibraryGroupMode.narrator,
  LibraryGroupMode.originalCountry,
  LibraryGroupMode.originalLanguage,
  LibraryGroupMode.originalPublicationDate,
  LibraryGroupMode.originalPublicationMonth,
  LibraryGroupMode.originalPublicationPlace,
  LibraryGroupMode.originalPublicationYear,
  LibraryGroupMode.originalPublisher,
  LibraryGroupMode.paperType,
  LibraryGroupMode.printedBy,
  LibraryGroupMode.coverArtist,
  LibraryGroupMode.editor,
  LibraryGroupMode.forewordAuthor,
  LibraryGroupMode.ghostWriter,
  LibraryGroupMode.illustrator,
  LibraryGroupMode.photography,
  LibraryGroupMode.translator,
  LibraryGroupMode.collectionStatus,
  LibraryGroupMode.condition,
  LibraryGroupMode.location,
  LibraryGroupMode.addedDate,
  LibraryGroupMode.addedMonth,
  LibraryGroupMode.addedYear,
  LibraryGroupMode.modifiedDate,
  LibraryGroupMode.modifiedMonth,
  LibraryGroupMode.myRating,
  LibraryGroupMode.owner,
  LibraryGroupMode.reader,
  LibraryGroupMode.readingStatus,
  LibraryGroupMode.tags,
};

const Set<LibrarySortColumn> _bookMediaSortColumns = {
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.series,
  LibrarySortColumn.publisher,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.condition,
  LibrarySortColumn.price,
  LibrarySortColumn.location,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.wishlist,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.pageCount,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.imprint,
};

const Set<LibrarySortColumn> _bookReleaseSortColumns = {
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.variant,
  LibrarySortColumn.format,
  LibrarySortColumn.publisher,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.barcode,
  LibrarySortColumn.condition,
  LibrarySortColumn.price,
  LibrarySortColumn.location,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.wishlist,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.pageCount,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.imprint,
};
