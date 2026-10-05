import '../music_module_dependencies.dart';
import 'music_kind_configuration.dart';
import '../actions/music_log_listen_action.dart';
import '../add/music_add_contribution.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

final musicKindPersonalFieldContributor = LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.music,
  fields: [
    for (final field in commonPersonalLibraryFields)
      relabelPersonalLibraryField(
          field,
          switch (field.key) {
            'market_value_cents' => 'Current Value',
            'owner_label' => 'Owner',
            'rating' => 'My Rating',
            'collection_status' => 'Collection Status',
            _ => field.label,
          }),
    const PersonalLibraryFieldSpec(
        key: 'quantity',
        label: 'Quantity',
        group: 'Collection state',
        syncable: true,
        editor: PersonalLibraryFieldEditor.integer,
        area: PersonalLibraryFieldArea.statusStrip,
        editOrder: 2,
        minimum: 1,
        defaultInteger: 1),
    const PersonalLibraryFieldSpec(
        key: 'media_condition',
        label: 'Media Condition',
        group: 'Collection state',
        syncable: true),
    const PersonalLibraryFieldSpec(
        key: 'purchase_date_parts',
        label: 'Purchase Date',
        group: 'Acquisition',
        syncable: true),
    const PersonalLibraryFieldSpec(
        key: 'last_cleaned_date_parts',
        label: 'Last Cleaned Date',
        group: 'Maintenance',
        syncable: true),
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
    PersonalLibraryFieldSpec(
      key: 'last_cleaned_date',
      label: 'Last Cleaned Date',
      group: 'Maintenance',
      editor: PersonalLibraryFieldEditor.partialDate,
      area: PersonalLibraryFieldArea.personalFields,
      editOrder: 7,
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

final musicKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem: LibraryTargetLabel(singular: 'Album', plural: 'Albums'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final musicKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.listen,
  writableTargets: {LibraryTrackingTarget.libraryEntry},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
);

final musicKindEntryPolicy =
    const LibraryEntryPolicyCapability.allowEverywhere();

final musicKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
  catalogItemSemanticActions: [
    // Listening history belongs to the concrete catalog item, matching the
    // Music tracking topology and listening-event storage.
    LibraryTargetSemanticActionDefinition(
      id: 'music.log_listen',
      label: 'Log listen',
      icon: Icons.headphones_outlined,
      invoke: runMusicLogListenAction,
    ),
  ],
);

final musicKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildMusicCatalogItemInspectorHero,
      sectionsBuilder: buildMusicCatalogItemInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildMusicLibraryEntryInspectorHero,
      sectionsBuilder: buildMusicLibraryEntryInspectorSections,
    ),
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
