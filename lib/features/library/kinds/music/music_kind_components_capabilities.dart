import 'music_module_dependencies.dart';
import 'music_kind_components_support.dart';

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

final musicKindWorkCapability = const DefaultWorkProjectionCapability();

final musicKindReleaseCapability =
    const MusicReleaseProjectionCapability<MusicWorkspaceProjection>();

final musicKindReleaseDetailSource = null;

final musicKindCatalogTarget = const MusicCatalogTargetCapability();

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
  accent: Color(0xFFFDAD49),
  preferencePrefix: 'music',
  routeSegments: ['music'],
  mediaFamily: 'audio',
  normalizeCatalogLabels: true,
);

final musicKindMetadata = const LibraryMetadataCapability(
  defaultProviderId: 'musicbrainz',
  catalogMetadataDecoder: MusicReleaseGroup.fromJson,
  searchQueryBuilder: musicMetadataSearchQuery,
  supportsServerCompare: true,
  compareBuilder: buildMusicMetadataComparePanels,
  providers: [musicBrainzMetadataProvider],
);

final musicKindHierarchy = const LibraryHierarchyCapability(
  childrenTitleBuilder: musicChildrenTitle,
  fetchChildrenCallback: fetchMusicTracks,
);

final musicKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Album', plural: 'Albums'),
  release: LibraryEntityLabel(singular: 'Release', plural: 'Releases'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final musicKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.listen,
  writableTargets: {LibraryTrackingTargetScope.release},
  aggregateTargets: {LibraryTrackingTargetScope.work},
  lookupScope: LibraryTrackingLookupScope.exactCatalog,
  ownedTrackingTarget: LibraryOwnedTrackingTarget.catalog,
);

final musicKindOwnership = const LibraryOwnershipCapability.releaseOnly();

final musicKindProviderPreviewPolicy = const LibraryProviderPreviewPolicy(
  preferredSource: LibraryProviderPreviewSource.typedCandidate,
);

final musicKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
  copy: LibraryEntityActionSet.copy,
  semanticActions: {
    LibraryEntityScope.release: [
      LibraryEntitySemanticActionDefinition(
        id: 'music.log_listen',
        label: 'Log listen',
        icon: Icons.headphones_outlined,
        invoke: (context) => context.onOpenDetails?.call(),
      ),
    ],
  },
);

final musicKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildMusicWorkInspectorHero,
        sectionsBuilder: buildMusicWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.release,
        heroBuilder: buildMusicReleaseInspectorHero,
        sectionsBuilder: buildMusicReleaseInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildMusicCopyInspectorHero,
        sectionsBuilder: buildMusicCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
  personalDetailFieldsBuilder: buildMusicPersonalDetailFields,
);

final musicKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<MusicReleaseGroup>(
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
