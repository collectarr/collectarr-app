import '../game_module_dependencies.dart';
import 'game_kind_configuration.dart';
import '../data/game_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

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
  catalogTransportCodec: GameCatalogTransportCodec(),
  searchQueryBuilder: gameMetadataSearchQuery,
);

final gameKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem: LibraryTargetLabel(singular: 'Game', plural: 'Games'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final gameKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.play,
  writableTargets: {LibraryTrackingTarget.libraryEntry},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
);

final gameKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.game,
  fields: [
    ...commonPersonalLibraryFields,
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
      key: 'game_pricecharting_id',
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

final gameKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
);

final gameKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildGameCatalogItemInspectorHero,
      sectionsBuilder: buildGameCatalogItemInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildGameLibraryEntryInspectorHero,
      sectionsBuilder: buildGameLibraryEntryInspectorSections,
    ),
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
