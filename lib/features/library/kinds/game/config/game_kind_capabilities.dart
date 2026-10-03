import '../game_module_dependencies.dart';
import 'game_kind_configuration.dart';

final gameKindPresentation = gamesLibraryMediaPresentation;

final gameKindPhysicalMediaFormats = gamePhysicalMediaFormats;

final gameKindTrackingProfile = gameTrackingProfile;

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
  catalogMetadataDecoder: GameCatalogMetadata.fromJson,
  searchQueryBuilder: gameMetadataSearchQuery,
);

final gameKindHierarchy = const LibraryHierarchyCapability(
  browserDelegateBuilder: LibraryNoopBrowserDelegate.new,
);

final gameKindEntityVocabulary = const LibraryEntityVocabulary(
  catalogItem: LibraryEntityLabel(singular: 'Game', plural: 'Games'),
  libraryEntry: LibraryEntityLabel(singular: 'Entry', plural: 'Entries'),
);

final gameKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.play,
  writableTargets: {LibraryTrackingTargetScope.catalogItem},
  aggregateTargets: {LibraryTrackingTargetScope.catalogItem},
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
  catalogItem: LibraryEntityActionSet.catalogItem,
  libraryEntry: LibraryEntityActionSet.libraryEntry,
);

final gameKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.catalogItem,
        heroBuilder: buildGameWorkInspectorHero,
        sectionsBuilder: buildGameWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.libraryEntry,
        heroBuilder: buildGameCopyInspectorHero,
        sectionsBuilder: buildGameCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
);

final gameKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<GameCatalogMetadata>(
  gameLinkedMetadata,
  gameLinkedMetadataValues,
);

final gameKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in gameTransferableFields) field.key,
  ],
  kindFields: [
    ...gameUniversalTransferableFields,
    ...gameTransferableFields,
  ],
);

final gameKindStats = const GameStatsCapability();
