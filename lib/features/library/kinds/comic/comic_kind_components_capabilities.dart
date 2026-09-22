part of 'comic_kind_components.dart';

final comicKindPresentation = comicLibraryMediaPresentation;

final comicKindPhysicalMediaFormats = comicPhysicalMediaFormats;

final comicKindTrackingProfile = comicTrackingProfile;

final comicKindWorkCapability = const DefaultWorkProjectionCapability();

final comicKindCatalogTarget = const ComicCatalogTargetCapability();

final comicKindViewProfile = comicsWorkspaceViewProfile;

final comicKindReleaseCapability = comic_release.comicKindReleaseCapability;

final comicKindReleaseDetailSource = comic_release.comicKindReleaseDetailSource;

final comicKindUiPolicy = const LibraryUiPolicy();

final comicKindSearchTargetOptions = const <LibrarySearchTarget>[];

final comicKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.comic,
  singularLabel: 'Comic',
  pluralLabel: 'Comics',
  title: 'Comics',
  icon: Icons.collections_bookmark_outlined,
  accent: Color(0xFF44BFE7),
  preferencePrefix: 'comics',
  routeSegments: ['comics', 'comic'],
  mediaFamily: 'print',
  toolbarActions: [
    ...kDefaultLibraryToolbarActions,
    LibraryToolbarActionId.readingQueue,
    LibraryToolbarActionId.reassignIndex,
  ],
);

final comicKindMetadata = LibraryMetadataCapability(
  defaultProviderId: 'gcd',
  catalogMetadataDecoder: ComicMedia.fromJson,
  searchQueryBuilder: _comicMetadataSearchQuery,
  supportsServerCompare: true,
  usesTreeProviderCandidates: true,
  compareBuilder: buildComicMetadataComparePanels,
  providers: [
    gcdMetadataProvider,
    comicVineMetadataProvider,
    mangadexMetadataProvider,
    anilistMetadataProvider,
    hardcoverMetadataProvider,
  ],
);

final comicKindHierarchy = const LibraryHierarchyCapability(
  fetchChildrenCallback: _fetchComicVolumes,
  childrenTitleBuilder: _comicChildrenTitle,
  contractDiagnosticLabelBuilder: _comicHierarchyContractDiagnosticLabel,
);

final comicKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Issue', plural: 'Issues'),
  release: LibraryEntityLabel(singular: 'Variant', plural: 'Variants'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final comicKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTargetScope.content},
  aggregateTargets: {LibraryTrackingTargetScope.work},
  contentTargets: {LibraryTrackingTargetScope.content},
);

final comicKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
  copy: LibraryEntityActionSet.copy,
  semanticActions: {
    LibraryEntityScope.work: [
      LibraryEntitySemanticActionDefinition(
        id: 'comic.missing_issues',
        label: 'Missing issues',
        icon: Icons.find_in_page_outlined,
        invoke: (context) => context.onOpenDetails?.call(),
      ),
    ],
  },
);

final comicKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildComicWorkInspectorHero,
        sectionsBuilder: buildComicWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.release,
        heroBuilder: buildComicReleaseInspectorHero,
        sectionsBuilder: buildComicReleaseInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildComicCopyInspectorHero,
        sectionsBuilder: buildComicCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
  personalDetailFieldsBuilder: buildComicPersonalDetailFields,
);

final comicKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<ComicMedia>(
  _comicLinkedMetadata,
  _comicLinkedMetadataValues,
);

final comicKindRelations = comicRelationCapability;

final comicKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: _comicTransferableFieldKeys,
  kindFields: [
    ..._comicUniversalTransferableFields,
    ...comicTransferableFieldDefinitions,
  ],
);

final comicKindStats = const ComicStatsCapability();

final comicKindValue = const ComicValueCapability();

