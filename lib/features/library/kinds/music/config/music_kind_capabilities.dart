import '../music_module_dependencies.dart';
import 'music_kind_configuration.dart';
import '../actions/music_log_listen_action.dart';
import '../add/music_add_contribution.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';

final musicKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.music,
  fields: [
    PersonalLibraryFieldSpec(
      key: 'storage_device',
      label: 'Storage device',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'storage_slot',
      label: 'Storage slot',
      group: 'Storage',
    ),
  ],
);

final musicKindPresentation = musicLibraryMediaPresentation;

final musicKindPhysicalMediaFormats = musicPhysicalMediaFormats;

final musicKindSearchTargetOptions = const <LibrarySearchTarget>[
  LibrarySearchTarget.all,
  LibrarySearchTarget.mediaOnly,
  LibrarySearchTarget.tracksOnly,
];

final musicKindTrackingProfile = musicTrackingProfile;

final LibraryRelationCapability? musicKindRelations = null;

final LibraryValueCapability? musicKindValue = null;

final musicKindToolbar = null;

final musicKindUiPolicy = const LibraryUiPolicy(
  coverAspectRatio: 1.0,
);

final musicKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.music,
  musicKindUiPolicy,
);

final musicKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.music,
  singularLabel: 'Music',
  pluralLabel: 'Music',
  title: 'Music',
  icon: Icons.music_note,
  accent: Color(0xFFF2932F),
  preferencePrefix: 'music',
  routeSegments: ['music'],
  mediaFamily: 'audio',
  normalizeCatalogLabels: true,
);

final musicKindMetadata = const LibraryMetadataCapability(
  catalogMetadataDecoder: MusicCatalogMapper.fromCatalogPayload,
  searchQueryBuilder: musicMetadataSearchQuery,
  catalogSearchBuilder: searchMusicCatalogItems,
  catalogSearchResultsAreDetailed: true,
  supportsServerCompare: true,
  compareBuilder: buildMusicMetadataComparePanels,
);

final musicKindHierarchy = const LibraryHierarchyCapability(
  childrenTitleBuilder: musicChildrenTitle,
  fetchChildrenCallback: fetchMusicTracks,
);

final musicKindEntityVocabulary = const LibraryEntityVocabulary(
  catalogItem: LibraryEntityLabel(singular: 'Album', plural: 'Albums'),
  libraryEntry: LibraryEntityLabel(singular: 'Entry', plural: 'Entries'),
);

final musicKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.listen,
  writableTargets: {LibraryTrackingTargetScope.catalogItem},
  aggregateTargets: {LibraryTrackingTargetScope.catalogItem},
  lookupScope: LibraryTrackingLookupScope.exactCatalog,
);

final musicKindEntryPolicy =
    const LibraryEntryPolicyCapability.allowEverywhere();

final musicKindActions = const LibraryEntityActionCapability(
  catalogItem: LibraryEntityActionSet.catalogItem,
  libraryEntry: LibraryEntityActionSet.libraryEntry,
  semanticActions: {
    // Listening history belongs to the concrete catalog item, matching the
    // Music tracking topology and listening-event storage.
    LibraryEntityScope.catalogItem: [
      LibraryEntitySemanticActionDefinition(
        id: 'music.log_listen',
        label: 'Log listen',
        icon: Icons.headphones_outlined,
        invoke: runMusicLogListenAction,
      ),
    ],
  },
);

final musicKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.catalogItem,
        heroBuilder: buildMusicWorkInspectorHero,
        sectionsBuilder: buildMusicWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.libraryEntry,
        heroBuilder: buildMusicCopyInspectorHero,
        sectionsBuilder: buildMusicCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
  personalDetailFieldsBuilder: buildMusicPersonalDetailFields,
);

final musicKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<MusicAlbum>(
  musicLinkedMetadata,
  musicLinkedMetadataValues,
);

final musicKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in musicTransferableFields) field.key,
  ],
  kindFields: [
    ...musicUniversalTransferableFields,
    ...musicTransferableFields,
  ],
);

final musicKindStats = const MusicStatsCapability();
