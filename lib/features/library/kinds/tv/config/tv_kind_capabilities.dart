import '../tv_module_dependencies.dart';
import 'tv_kind_configuration.dart';
import '../add/tv_add_contribution.dart';

final tvKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.tv,
  fields: [
    PersonalLibraryFieldSpec(
      key: 'features',
      label: 'Features',
      group: 'Storage',
      syncable: true,
    ),
    PersonalLibraryFieldSpec(
      key: 'hdr_formats',
      label: 'HDR formats',
      group: 'Storage',
      syncable: true,
    ),
    PersonalLibraryFieldSpec(
      key: 'box_set_id',
      label: 'Box set ID',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'box_set_name',
      label: 'Box set name',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'region',
      label: 'Region',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'packaging',
      label: 'Packaging',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'distributor',
      label: 'Distributor',
      group: 'Storage',
    ),
  ],
);

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
  searchQueryBuilder: tvMetadataSearchQuery,
  providers: [tmdbMetadataProvider],
);

final tvKindUiPolicy = const LibraryUiPolicy(
  wideDialog: true,
);

final tvKindHierarchy = const LibraryHierarchyCapability(
  fetchChildrenCallback: fetchTvSeasons,
  childrenTitleBuilder: tvChildrenTitle,
);

final tvKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Series', plural: 'Series'),
  release: LibraryEntityLabel(singular: 'Release', plural: 'Releases'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final tvKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.watch,
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
  tvLinkedMetadata,
  tvLinkedMetadataValues,
);

final tvKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in tvTransferableFields) field.key,
  ],
  kindFields: [
    ...tvUniversalTransferableFields,
    ...tvTransferableFields,
  ],
);

final tvKindStats = const TvStatsCapability();
