import '../book_module_dependencies.dart';
import 'book_kind_configuration.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

final bookKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.book,
  fields: [
    ...commonPersonalLibraryFields,
    PersonalLibraryFieldSpec(
      key: 'signed_by',
      label: 'Signed by',
      group: 'Collection details',
      syncable: true,
    ),
  ],
);

final bookKindPresentation = bookLibraryMediaPresentation;

final bookKindPhysicalMediaFormats = bookPhysicalMediaFormats;

final bookKindTrackingProfile = bookTrackingProfile;

final bookKindUiPolicy = const LibraryUiPolicy();

final LibraryValueCapability? bookKindValue = null;

final LibraryRelationCapability? bookKindRelations = null;

final bookKindToolbar = null;

final bookKindSearchTargetOptions = const <LibrarySearchTarget>[];

final bookKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.book,
  const LibraryUiPolicy(),
);

final bookKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.book,
  singularLabel: 'Book',
  pluralLabel: 'Books',
  title: 'Books',
  icon: Icons.book_outlined,
  accent: Color(0xFFC78446),
  preferencePrefix: 'books',
  routeSegments: ['books', 'book'],
  mediaFamily: 'print',
  toolbarActions: [
    ...kDefaultLibraryToolbarActions,
    LibraryToolbarActionId.readingQueue,
  ],
);

final bookKindMetadata = const LibraryMetadataCapability(
  catalogMetadataDecoder: BookCatalogMetadata.fromJson,
  searchQueryBuilder: bookMetadataSearchQuery,
);

final bookKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem: LibraryTargetLabel(singular: 'Book', plural: 'Books'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final bookKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTarget.libraryEntry},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
);

final bookKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
);

final bookKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildBookCatalogItemInspectorHero,
      sectionsBuilder: buildBookCatalogItemInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildBookLibraryEntryInspectorHero,
      sectionsBuilder: buildBookLibraryEntryInspectorSections,
    ),
  ),
  showsDefaultPersonalSection: true,
  supportsLibraryEntryImages: false,
);

final bookKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<BookCatalogMetadata>(
  bookLinkedMetadata,
  bookLinkedMetadataValues,
);

final bookKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in bookTransferableFields) field.key,
  ],
  kindFields: [
    ...bookUniversalTransferableFields,
    ...bookTransferableFields,
  ],
);

final bookKindStats = const BookStatsCapability();
