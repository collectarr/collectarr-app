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
  catalogMetadataDecoder: MovieCatalogMetadata.fromJson,
  searchQueryBuilder: movieMetadataSearchQuery,
);

final movieKindUiPolicy = const LibraryUiPolicy(
  wideDialog: true,
);

final movieKindHierarchy = LibraryHierarchyCapability(
  browserDelegateBuilder: buildMovieBrowserDelegate,
);

final movieKindEntityVocabulary = const LibraryEntityVocabulary(
  catalogItem: LibraryEntityLabel(singular: 'Movie', plural: 'Movies'),
  libraryEntry: LibraryEntityLabel(singular: 'Entry', plural: 'Entries'),
);

final movieKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.watch,
  writableTargets: {LibraryTrackingTargetScope.catalogItem},
  aggregateTargets: {LibraryTrackingTargetScope.catalogItem},
);

final movieKindActions = const LibraryEntityActionCapability(
  catalogItem: LibraryEntityActionSet.catalogItem,
  libraryEntry: LibraryEntityActionSet.libraryEntry,
);

final movieKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.catalogItem,
        heroBuilder: buildMovieInspectorHero,
        sectionsBuilder: buildMovieInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.libraryEntry,
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
