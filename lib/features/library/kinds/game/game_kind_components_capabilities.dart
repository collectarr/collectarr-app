part of 'game_kind_components.dart';

final gameKindPresentation = gamesLibraryMediaPresentation;

final gameKindPhysicalMediaFormats = gamePhysicalMediaFormats;

final gameKindTrackingProfile = gameTrackingProfile;

final gameKindWorkCapability = const DefaultWorkProjectionCapability();

final gameKindReleaseCapability = game_release.gameKindReleaseCapability;

final gameKindReleaseDetailSource = game_release.gameKindReleaseDetailSource;

final gameKindCatalogTarget = const GameCatalogTargetCapability();

final gameKindUiPolicy = const LibraryUiPolicy();

final LibraryRelationCapability? gameKindRelations = null;

final LibraryValueCapability? gameKindValue = null;

final gameKindToolbar = null;

final gameKindSearchTargetOptions = const <LibrarySearchTarget>[];

final gameKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.game,
  const LibraryUiPolicy(),
);

final gameKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.game,
  singularLabel: 'Game',
  pluralLabel: 'Games',
  title: 'Games',
  icon: Icons.sports_esports,
  accent: Color(0xFFF64458),
  preferencePrefix: 'games',
  routeSegments: ['games', 'game'],
  mediaFamily: 'game',
);

final gameKindMetadata = const LibraryMetadataCapability(
  defaultProviderId: 'igdb',
  catalogMetadataDecoder: GameCatalogMetadata.fromJson,
  searchQueryBuilder: _gameMetadataSearchQuery,
  providers: [igdbMetadataProvider],
);

final gameKindHierarchy = const LibraryHierarchyCapability(
  browserDelegateBuilder: buildReleaseFolderBrowserDelegate,
);

final gameKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Game', plural: 'Games'),
  release: LibraryEntityLabel(singular: 'Edition', plural: 'Editions'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final gameKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.play,
  writableTargets: {LibraryTrackingTargetScope.release},
  aggregateTargets: {LibraryTrackingTargetScope.work},
);

final gameKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.game,
  fields: [
    PersonalLibraryFieldSpec(
      key: 'game_completeness',
      label: 'Game completeness',
      group: 'Games',
    ),
    PersonalLibraryFieldSpec(
      key: 'game_has_box',
      label: 'Game has box',
      group: 'Games',
    ),
    PersonalLibraryFieldSpec(
      key: 'game_has_manual',
      label: 'Game has manual',
      group: 'Games',
    ),
    PersonalLibraryFieldSpec(
      key: 'game_price_charting_id',
      label: 'Game PriceCharting ID',
      group: 'Games',
    ),
    PersonalLibraryFieldSpec(
      key: 'game_core_region',
      label: 'Game core region',
      group: 'Games',
    ),
    PersonalLibraryFieldSpec(
      key: 'game_value_is_locked',
      label: 'Game value locked',
      group: 'Games',
    ),
  ],
);

final gameKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
  copy: LibraryEntityActionSet.copy,
);

final gameKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildGameWorkInspectorHero,
        sectionsBuilder: buildGameWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.release,
        heroBuilder: buildGameReleaseInspectorHero,
        sectionsBuilder: buildGameReleaseInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildGameCopyInspectorHero,
        sectionsBuilder: buildGameCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
);

final gameKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<GameCatalogMetadata>(
  _gameLinkedMetadata,
  _gameLinkedMetadataValues,
);

final gameKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in _gameTransferableFields) field.key,
  ],
  kindFields: [
    ..._gameUniversalTransferableFields,
    ..._gameTransferableFields,
  ],
);

final gameKindStats = const GameStatsCapability();
