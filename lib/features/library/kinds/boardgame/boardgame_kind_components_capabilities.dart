part of 'boardgame_kind_components.dart';

final boardGameKindPresentation = boardGamesLibraryMediaPresentation;

final boardGameKindPhysicalMediaFormats = boardGamePhysicalMediaFormats;

final boardGameKindTrackingProfile = boardGameTrackingProfile;

final boardGameKindWorkCapability = const DefaultWorkProjectionCapability();

final boardGameKindReleaseCapability =
    boardgame_release.boardGameKindReleaseCapability;

final boardGameKindReleaseDetailSource =
    boardgame_release.boardGameKindReleaseDetailSource;

final boardGameKindCatalogTarget = const BoardGameCatalogTargetCapability();

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
  defaultProviderId: 'bgg',
  catalogMetadataDecoder: BoardGameMetadata.fromJson,
  searchQueryBuilder: _boardGameMetadataSearchQuery,
  providers: [bggMetadataProvider],
);

final boardGameKindHierarchy = const LibraryHierarchyCapability(
  browserDelegateBuilder: buildReleaseFolderBrowserDelegate,
);

final boardGameKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Game', plural: 'Games'),
  release: LibraryEntityLabel(singular: 'Edition', plural: 'Editions'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final boardGameKindTrackingTopology = const LibraryTrackingTopology(
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
        heroBuilder: buildBoardGameWorkInspectorHero,
        sectionsBuilder: buildBoardGameWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.release,
        heroBuilder: buildBoardGameReleaseInspectorHero,
        sectionsBuilder: buildBoardGameReleaseInspectorSections,
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
  _boardGameLinkedMetadata,
  _boardGameLinkedMetadataValues,
);

final boardGameKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in _boardgameTransferableFields) field.key,
  ],
  kindFields: [
    ..._boardgameUniversalTransferableFields,
    ..._boardgameTransferableFields,
  ],
);

