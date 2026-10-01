import '../boardgame_module_dependencies.dart';
import 'boardgame_kind_configuration.dart';

final boardGameKindPresentation = boardGamesLibraryMediaPresentation;

final boardGameKindPhysicalMediaFormats = boardGamePhysicalMediaFormats;

final boardGameKindTrackingProfile = boardGameTrackingProfile;

final boardGameKindWorkCapability = const DefaultWorkProjectionCapability();

final boardGameKindReleaseCapability = null;

final boardGameKindReleaseDetailSource = null;

final boardGameKindCatalogTarget = const RootCatalogTargetCapability();

final boardGameKindUiPolicy = const LibraryUiPolicy();

final LibraryValueCapability? boardGameKindValue = null;

final LibraryRelationCapability? boardGameKindRelations = null;

final boardGameKindToolbar = null;

final boardGameKindSearchTargetOptions = const <LibrarySearchTarget>[];

final boardGameKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.boardgame,
  const LibraryUiPolicy(),
);

final boardGameKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.boardgame,
  singularLabel: 'Board Game',
  pluralLabel: 'Board Games',
  title: 'Board Games',
  icon: Icons.casino_outlined,
  accent: Color(0xFFE0A52B),
  preferencePrefix: 'boardgames',
  routeSegments: ['board-games', 'boardgames', 'boardgame'],
  mediaFamily: 'game',
  normalizeCatalogLabels: true,
);

final boardGameKindMetadata = const LibraryMetadataCapability(
  catalogMetadataDecoder: BoardGameMetadata.fromJson,
  searchQueryBuilder: boardGameMetadataSearchQuery,
);

final boardGameKindHierarchy = const LibraryHierarchyCapability(
  browserDelegateBuilder: LibraryNoopBrowserDelegate.new,
);

final boardGameKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Game', plural: 'Games'),
  release: LibraryEntityLabel(singular: 'Edition', plural: 'Editions'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final boardGameKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.play,
  writableTargets: {LibraryTrackingTargetScope.work},
  aggregateTargets: {LibraryTrackingTargetScope.work},
);

final boardGameKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
  copy: LibraryEntityActionSet.copy,
);

final boardGameKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildBoardGameCatalogItemInspectorHero,
        sectionsBuilder: buildBoardGameCatalogItemInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildBoardGameCopyInspectorHero,
        sectionsBuilder: buildBoardGameCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
);

final boardGameKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<BoardGameMetadata>(
  boardGameLinkedMetadata,
  boardGameLinkedMetadataValues,
);

final boardGameKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in boardgameTransferableFields) field.key,
  ],
  kindFields: [
    ...boardgameUniversalTransferableFields,
    ...boardgameTransferableFields,
  ],
);
