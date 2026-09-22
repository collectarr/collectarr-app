part of 'book_kind_components.dart';

final bookKindPresentation = bookLibraryMediaPresentation;

final bookKindPhysicalMediaFormats = bookPhysicalMediaFormats;

final bookKindTrackingProfile = bookTrackingProfile;

final bookKindWorkCapability = const DefaultWorkProjectionCapability();

final bookKindReleaseCapability = book_release.bookKindReleaseCapability;

final bookKindReleaseDetailSource = book_release.bookKindReleaseDetailSource;

final bookKindCatalogTarget = const BookCatalogTargetCapability();

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
  defaultProviderId: 'hardcover',
  catalogMetadataDecoder: BookCatalogMetadata.fromJson,
  searchQueryBuilder: _bookMetadataSearchQuery,
  providers: [
    hardcoverMetadataProvider,
    openLibraryMetadataProvider,
  ],
);

final bookKindHierarchy = LibraryHierarchyCapability(
  browserDelegateBuilder: buildReleaseFolderBrowserDelegate,
  fetchChildrenCallback: _fetchBookVolumes,
  childrenTitleBuilder: _bookChildrenTitle,
);

final bookKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Book', plural: 'Books'),
  release: LibraryEntityLabel(singular: 'Edition', plural: 'Editions'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final bookKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTargetScope.content},
  aggregateTargets: {LibraryTrackingTargetScope.work},
  contentTargets: {LibraryTrackingTargetScope.content},
);

final bookKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
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
        scope: LibraryEntityScope.release,
        heroBuilder: buildBookReleaseInspectorHero,
        sectionsBuilder: buildBookReleaseInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildBookCopyInspectorHero,
        sectionsBuilder: buildBookCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: true,
  showsCreatorSpotlight: true,
  supportsOwnedItemImages: false,
);

final bookKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<BookCatalogMetadata>(
  _bookLinkedMetadata,
  _bookLinkedMetadataValues,
);

final bookKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in _bookTransferableFields) field.key,
  ],
  kindFields: [
    ..._bookUniversalTransferableFields,
    ..._bookTransferableFields,
  ],
);

final bookKindStats = const BookStatsCapability();

