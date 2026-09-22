part of 'anime_kind_components.dart';

final animeKindPresentation = animeLibraryMediaPresentation;

final animeKindPhysicalMediaFormats = animePhysicalMediaFormats;

final animeKindTrackingProfile = animeTrackingProfile;

final animeKindWorkCapability = const DefaultWorkProjectionCapability();

final animeKindReleaseCapability =
    const AnimeReleaseProjectionCapability<LibraryWorkspaceDto>();

final animeKindReleaseDetailSource = const AnimeReleaseDetailSource();

final animeKindCatalogTarget = const AnimeCatalogTargetCapability();

final LibraryRelationCapability? animeKindRelations = null;

final LibraryValueCapability? animeKindValue = null;

final animeKindToolbar = null;

final animeKindSearchTargetOptions = const <LibrarySearchTarget>[];

final animeKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.anime,
  const LibraryUiPolicy(),
);

final animeKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.anime,
  singularLabel: 'Anime',
  pluralLabel: 'Anime',
  title: 'Anime',
  icon: Icons.movie_filter_outlined,
  accent: Color(0xFFC94DFF),
  preferencePrefix: 'anime',
  routeSegments: ['anime'],
  mediaFamily: 'video',
);

final animeKindMetadata = const LibraryMetadataCapability(
  defaultProviderId: 'anilist',
  catalogMetadataDecoder: AnimeMetadata.fromJson,
  searchQueryBuilder: _animeMetadataSearchQuery,
  usesTreeProviderCandidates: true,
  providers: [anilistMetadataProvider],
);

final animeKindHierarchy = const LibraryHierarchyCapability(
  fetchChildrenCallback: _fetchAnimeEpisodes,
  childrenTitleBuilder: _animeChildrenTitle,
);

final animeKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Series', plural: 'Series'),
  release: LibraryEntityLabel(singular: 'Release', plural: 'Releases'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final animeKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.watch,
  writableTargets: {LibraryTrackingTargetScope.content},
  aggregateTargets: {LibraryTrackingTargetScope.work},
  contentTargets: {LibraryTrackingTargetScope.content},
);

final animeKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
  copy: LibraryEntityActionSet.copy,
);

final animeKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildAnimeWorkInspectorHero,
        sectionsBuilder: buildAnimeWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.release,
        heroBuilder: buildAnimeReleaseInspectorHero,
        sectionsBuilder: buildAnimeReleaseInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildAnimeCopyInspectorHero,
        sectionsBuilder: buildAnimeCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
  trackingEditor: LibraryTrackingEditorCapability(
    builder: buildAnimeTrackingEditorExtension,
  ),
);

final animeKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<AnimeMetadata>(
  _animeLinkedMetadata,
  _animeLinkedMetadataValues,
);

final animeKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in _animeTransferableFields) field.key,
  ],
  kindFields: [
    ..._animeUniversalTransferableFields,
    ..._animeTransferableFields,
  ],
);

final animeKindStats = const AnimeStatsCapability();

final animeKindUiPolicy = const LibraryUiPolicy(
  wideDialog: true,
);

