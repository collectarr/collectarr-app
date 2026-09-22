import '../movie_module_dependencies.dart';
import 'movie_kind_configuration.dart';

final movieKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.movie,
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

final movieKindPresentation = moviesLibraryMediaPresentation;

final movieKindPhysicalMediaFormats = moviePhysicalMediaFormats;

final movieKindTrackingProfile = movieTrackingProfile;

final movieKindWorkCapability = const DefaultWorkProjectionCapability();

final movieKindReleaseCapability =
    const MovieReleaseProjectionCapability<LibraryWorkspaceDto>();

final movieKindReleaseDetailSource = const MovieReleaseDetailSource();

final movieKindCatalogTarget = const MovieCatalogTargetCapability();

final LibraryRelationCapability? movieKindRelations = null;

final movieKindToolbar = null;

final movieKindSearchTargetOptions = const <LibrarySearchTarget>[];

final movieKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.movie,
  const LibraryUiPolicy(
    wideDialog: true,
  ),
);

final movieKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.movie,
  singularLabel: 'Movie',
  pluralLabel: 'Movies',
  title: 'Movies',
  icon: Icons.movie_outlined,
  accent: Color(0xFF42AA55),
  preferencePrefix: 'movies',
  routeSegments: ['movies', 'movie'],
  mediaFamily: 'video',
);

final movieKindMetadata = const LibraryMetadataCapability(
  defaultProviderId: 'tmdb',
  catalogMetadataDecoder: MovieCatalogMetadata.fromJson,
  searchQueryBuilder: movieMetadataSearchQuery,
  providers: [tmdbMetadataProvider],
);

final movieKindUiPolicy = const LibraryUiPolicy(
  wideDialog: true,
);

final movieKindHierarchy = LibraryHierarchyCapability(
  browserDelegateBuilder: buildMovieBrowserDelegate,
);

final movieKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Movie', plural: 'Movies'),
  release: LibraryEntityLabel(singular: 'Edition', plural: 'Editions'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final movieKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.watch,
  writableTargets: {LibraryTrackingTargetScope.work},
  aggregateTargets: {LibraryTrackingTargetScope.work},
);

final movieKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
  copy: LibraryEntityActionSet.copy,
);

final movieKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildMovieWorkInspectorHero,
        sectionsBuilder: buildMovieWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.release,
        heroBuilder: buildMovieReleaseInspectorHero,
        sectionsBuilder: buildMovieReleaseInspectorSections,
        detailPageBuilder: buildLibraryReleaseDetailPage,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildMovieCopyInspectorHero,
        sectionsBuilder: buildMovieCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
);

final movieKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<MovieCatalogMetadata>(
  movieLinkedMetadata,
  movieLinkedMetadataValues,
);

final movieKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in movieTransferableFields) field.key,
  ],
  kindFields: [
    ...movieUniversalTransferableFields,
    ...movieTransferableFields,
  ],
);

final movieKindStats = const MovieStatsCapability();

final movieKindValue = const MovieValueCapability();
