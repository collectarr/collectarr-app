import '../book_module_dependencies.dart';
import 'book_kind_configuration.dart';

final bookKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.book,
  fields: [
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

final bookKindWorkCapability = const DefaultWorkProjectionCapability();

final ReleaseProjectionCapability<BookWorkspaceDto>? bookKindReleaseCapability =
    null;

final bookKindReleaseDetailSource = null;

final bookKindCatalogTarget = const RootCatalogTargetCapability();

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

final bookKindHierarchy = const LibraryHierarchyCapability();

final bookKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Book', plural: 'Books'),
  release: LibraryEntityLabel(singular: 'Edition', plural: 'Editions'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final bookKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTargetScope.work},
  aggregateTargets: {LibraryTrackingTargetScope.work},
);

final bookKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet(),
  copy: LibraryEntityActionSet.copy,
);

final bookKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildBookWorkInspectorHero,
        sectionsBuilder: buildBookWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildBookCopyInspectorHero,
        sectionsBuilder: buildBookCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: true,
  supportsOwnedItemImages: false,
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
