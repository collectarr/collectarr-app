import '../boardgame_module_dependencies.dart';
import 'boardgame_kind_configuration.dart';

final boardGameKindPresentation = boardGamesLibraryMediaPresentation;

final boardGameKindPhysicalMediaFormats = boardGamePhysicalMediaFormats;

final boardGameKindTrackingProfile = boardGameTrackingProfile;

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
  catalogItem: LibraryEntityLabel(singular: 'Game', plural: 'Games'),
  libraryEntry: LibraryEntityLabel(singular: 'Entry', plural: 'Entries'),
);

final boardGameKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.play,
  writableTargets: {LibraryTrackingTargetScope.catalogItem},
  aggregateTargets: {LibraryTrackingTargetScope.catalogItem},
);

final boardGameKindActions = const LibraryEntityActionCapability(
  catalogItem: LibraryEntityActionSet.catalogItem,
  libraryEntry: LibraryEntityActionSet.libraryEntry,
);

final boardGameKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.catalogItem,
        heroBuilder: buildBoardGameCatalogItemInspectorHero,
        sectionsBuilder: buildBoardGameCatalogItemInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.libraryEntry,
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
