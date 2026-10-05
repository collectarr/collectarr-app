import '../boardgame_module_dependencies.dart';
import 'boardgame_kind_configuration.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

final boardGameKindPersonalFieldContributor = LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.boardgame,
  fields: commonPersonalLibraryFields,
);

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

final boardGameKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem: LibraryTargetLabel(singular: 'Game', plural: 'Games'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final boardGameKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.play,
  writableTargets: {LibraryTrackingTarget.libraryEntry},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
);

final boardGameKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
);

final boardGameKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildBoardGameCatalogItemInspectorHero,
      sectionsBuilder: buildBoardGameCatalogItemInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildBoardGameLibraryEntryInspectorHero,
      sectionsBuilder: buildBoardGameLibraryEntryInspectorSections,
    ),
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
