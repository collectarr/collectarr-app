import '../tv_module_dependencies.dart';
import 'tv_kind_configuration.dart';
import '../add/tv_add_contribution.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

final tvKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.tv,
  fields: [
    ...commonPersonalLibraryFields,
    PersonalLibraryFieldSpec(
      key: 'features',
      label: 'Features',
      group: 'Storage',
      syncable: true,
    ),
    PersonalLibraryFieldSpec(
      key: 'hdr_formats',
      label: 'HDR formats',
      group: 'Storage',
      syncable: true,
    ),
    PersonalLibraryFieldSpec(
      key: 'box_set_id',
      label: 'Box set ID',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'box_set_name',
      label: 'Box set name',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'region',
      label: 'Region',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'packaging',
      label: 'Packaging',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'distributor',
      label: 'Distributor',
      group: 'Storage',
    ),
  ],
);

final tvKindPresentation = tvLibraryMediaPresentation;

final tvKindPhysicalMediaFormats = tvPhysicalMediaFormats;

final tvKindTrackingProfile = tvTrackingProfile;

final LibraryRelationCapability? tvKindRelations = null;

final LibraryValueCapability? tvKindValue = null;

final tvKindToolbar = null;

final tvKindSearchTargetOptions = const <LibrarySearchTarget>[];

final tvKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.tv,
  const LibraryUiPolicy(
    wideDialog: true,
  ),
);

final tvKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.tv,
  singularLabel: 'TV Show',
  pluralLabel: 'TV Shows',
  title: 'TV',
  icon: Icons.tv_outlined,
  accent: Color(0xFF00A7A0),
  preferencePrefix: 'tv',
  routeSegments: ['tv', 'tv-shows', 'tvshows'],
  mediaFamily: 'video',
  normalizeCatalogLabels: true,
);

final tvKindMetadata = const LibraryMetadataCapability(
  catalogMetadataDecoder: TvMetadata.fromJson,
  searchQueryBuilder: tvMetadataSearchQuery,
);

final tvKindUiPolicy = const LibraryUiPolicy(
  wideDialog: true,
);

final tvKindHierarchy = const LibraryHierarchyCapability(
  fetchChildrenCallback: fetchTvSeasons,
  childrenTitleBuilder: tvChildrenTitle,
);

final tvKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem:
      LibraryTargetLabel(singular: 'Season release', plural: 'Season releases'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final tvKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.watch,
  writableTargets: {LibraryTrackingTarget.content},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
  contentTargets: {LibraryTrackingTarget.content},
);

final tvKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
);

final tvKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildTvCatalogItemInspectorHero,
      sectionsBuilder: buildTvCatalogItemInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildTvLibraryEntryInspectorHero,
      sectionsBuilder: buildTvLibraryEntryInspectorSections,
    ),
  ),
  mediaDetailContributionBuilder: buildTvVideoDetailContribution,
  showsDefaultPersonalSection: false,
  trackingEditor: LibraryTrackingEditorCapability(
    builder: buildTvTrackingEditorExtension,
  ),
);

final tvKindLinkedMetadata = TypedLibraryLinkedMetadataCapability<TvMetadata>(
  tvLinkedMetadata,
  tvLinkedMetadataValues,
);

final tvKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in tvTransferableFields) field.key,
  ],
  kindFields: [
    ...tvUniversalTransferableFields,
    ...tvTransferableFields,
  ],
);

final tvKindStats = const TvStatsCapability();
