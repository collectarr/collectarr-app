part of 'tv_kind_components.dart';

final tvKindPresentation = tvLibraryMediaPresentation;

final tvKindPhysicalMediaFormats = tvPhysicalMediaFormats;

final tvKindTrackingProfile = tvTrackingProfile;

final tvKindWorkCapability = const DefaultWorkProjectionCapability();

final tvKindReleaseCapability =
    const TvReleaseProjectionCapability<LibraryWorkspaceDto>();

final tvKindReleaseDetailSource = const TvReleaseDetailSource();

final tvKindCatalogTarget = const TvCatalogTargetCapability();

final LibraryRelationCapability? tvKindRelations = null;

final LibraryValueCapability? tvKindValue = null;

final tvKindToolbar = null;

final tvKindSearchTargetOptions = const <LibrarySearchTarget>[];

final tvKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.tv,
  const LibraryUiPolicy(
    wideDialog: true,
  ),
);

final tvKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.tv,
  singularLabel: 'TV Show',
  pluralLabel: 'TV Shows',
  title: 'TV',
  icon: Icons.tv_outlined,
  accent: Color(0xFF00A7A0),
  preferencePrefix: 'tv',
  routeSegments: ['tv', 'tv-shows', 'tvshows'],
  mediaFamily: 'video',
  normalizeCatalogLabels: true,
);

final tvKindMetadata = const LibraryMetadataCapability(
  defaultProviderId: 'tmdb',
  catalogMetadataDecoder: TvSeriesMetadata.fromJson,
  searchQueryBuilder: _tvMetadataSearchQuery,
  providers: [tmdbMetadataProvider],
);

final tvKindUiPolicy = const LibraryUiPolicy(
  wideDialog: true,
);

final tvKindHierarchy = const LibraryHierarchyCapability(
  fetchChildrenCallback: _fetchTvSeasons,
  childrenTitleBuilder: _tvChildrenTitle,
);

final tvKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Series', plural: 'Series'),
  release: LibraryEntityLabel(singular: 'Release', plural: 'Releases'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final tvKindTrackingTopology = const LibraryTrackingTopology(
  writableTargets: {LibraryTrackingTargetScope.content},
  aggregateTargets: {LibraryTrackingTargetScope.work},
  contentTargets: {LibraryTrackingTargetScope.content},
);

final tvKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
  copy: LibraryEntityActionSet.copy,
);

final tvKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildTvWorkInspectorHero,
        sectionsBuilder: buildTvWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.release,
        heroBuilder: buildTvReleaseInspectorHero,
        sectionsBuilder: buildTvReleaseInspectorSections,
        detailPageBuilder: buildLibraryReleaseDetailPage,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildTvCopyInspectorHero,
        sectionsBuilder: buildTvCopyInspectorSections,
      ),
    ],
  ),
  mediaDetailContributionBuilder: buildTvVideoDetailContribution,
  showsDefaultPersonalSection: false,
  trackingEditor: LibraryTrackingEditorCapability(
    builder: buildTvTrackingEditorExtension,
  ),
);

final tvKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<TvSeriesMetadata>(
  _tvLinkedMetadata,
  _tvLinkedMetadataValues,
);

final tvKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in _tvTransferableFields) field.key,
  ],
  kindFields: [
    ..._tvUniversalTransferableFields,
    ..._tvTransferableFields,
  ],
);

final tvKindStats = const TvStatsCapability();

