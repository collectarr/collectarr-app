import '../comic_module_dependencies.dart';
import 'comic_kind_configuration.dart';
import '../actions/comic_missing_issues_action.dart';
import '../add/comic_add_contribution.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/release/comic_release_projection_capability.dart'
    as comic_release;

final comicKindPresentation = comicLibraryMediaPresentation;

final comicKindPhysicalMediaFormats = comicPhysicalMediaFormats;

final comicKindTrackingProfile = comicTrackingProfile;

final comicKindWorkCapability = const DefaultWorkProjectionCapability();

final comicKindCatalogTarget = const ComicCatalogTargetCapability();

final comicKindViewProfile = comicsWorkspaceViewProfile;

final comicKindReleaseCapability = comic_release.comicKindReleaseCapability;

final comicKindReleaseDetailSource = comic_release.comicKindReleaseDetailSource;

final comicKindUiPolicy = const LibraryUiPolicy();

final comicKindSearchTargetOptions = const <LibrarySearchTarget>[];

final comicKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.comic,
  singularLabel: 'Comic',
  pluralLabel: 'Comics',
  title: 'Comics',
  icon: Icons.collections_bookmark_outlined,
  accent: Color(0xFF44BFE7),
  preferencePrefix: 'comics',
  routeSegments: ['comics', 'comic'],
  mediaFamily: 'print',
  toolbarActions: [
    ...kDefaultLibraryToolbarActions,
    LibraryToolbarActionId.readingQueue,
    LibraryToolbarActionId.reassignIndex,
  ],
);

final comicKindMetadata = LibraryMetadataCapability(
  defaultProviderId: 'gcd',
  catalogMetadataDecoder: ComicMedia.fromJson,
  searchQueryBuilder: comicMetadataSearchQuery,
  supportsServerCompare: true,
  usesTreeProviderCandidates: true,
  compareBuilder: buildComicMetadataComparePanels,
  providers: [
    gcdMetadataProvider,
    comicVineMetadataProvider,
    mangadexMetadataProvider,
    anilistMetadataProvider,
    hardcoverMetadataProvider,
  ],
);

final comicKindHierarchy = const LibraryHierarchyCapability(
  fetchChildrenCallback: fetchComicVolumes,
  childrenTitleBuilder: comicChildrenTitle,
  contractDiagnosticLabelBuilder: comicHierarchyContractDiagnosticLabel,
);

final comicKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Issue', plural: 'Issues'),
  release: LibraryEntityLabel(singular: 'Variant', plural: 'Variants'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final comicKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTargetScope.content},
  aggregateTargets: {LibraryTrackingTargetScope.work},
  contentTargets: {LibraryTrackingTargetScope.content},
);

final comicKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.comic,
  fields: [
    PersonalLibraryFieldSpec(
      key: 'last_bag_board_date',
      label: 'Last bag/board date',
      group: 'Storage',
    ),
    PersonalLibraryFieldSpec(
      key: 'cover_price_cents',
      label: 'Cover price',
      group: 'Acquisition',
    ),
    PersonalLibraryFieldSpec(
      key: 'raw_or_slabbed',
      label: 'Raw or slabbed',
      group: 'Grading',
      syncable: true,
    ),
    PersonalLibraryFieldSpec(
      key: 'grading_company',
      label: 'Grading company',
      group: 'Grading',
      syncable: true,
    ),
    PersonalLibraryFieldSpec(
      key: 'grader_notes',
      label: 'Grader notes',
      group: 'Grading',
    ),
    PersonalLibraryFieldSpec(
      key: 'signed_by',
      label: 'Signed by',
      group: 'Grading',
      syncable: true,
    ),
    PersonalLibraryFieldSpec(
      key: 'label_type',
      label: 'Label type',
      group: 'Grading',
    ),
    PersonalLibraryFieldSpec(
      key: 'custom_label',
      label: 'Custom label',
      group: 'Grading',
    ),
    PersonalLibraryFieldSpec(
      key: 'page_quality',
      label: 'Page quality',
      group: 'Grading',
    ),
    PersonalLibraryFieldSpec(
      key: 'certification_number',
      label: 'Certification number',
      group: 'Grading',
    ),
    PersonalLibraryFieldSpec(
      key: 'keycomic',
      label: 'Key comic',
      group: 'Comic flags',
    ),
    PersonalLibraryFieldSpec(
      key: 'key_reason',
      label: 'Key reason',
      group: 'Comic flags',
    ),
    PersonalLibraryFieldSpec(
      key: 'key_category',
      label: 'Key category',
      group: 'Comic flags',
    ),
    PersonalLibraryFieldSpec(
      key: 'key_severity',
      label: 'Key severity',
      group: 'Comic flags',
    ),
  ],
);

final comicKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
  copy: LibraryEntityActionSet.copy,
  semanticActions: {
    LibraryEntityScope.work: [
      LibraryEntitySemanticActionDefinition(
        id: 'comic.missing_issues',
        label: 'Missing issues',
        icon: Icons.find_in_page_outlined,
        invoke: runComicMissingIssuesAction,
      ),
    ],
  },
);

final comicKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildComicWorkInspectorHero,
        sectionsBuilder: buildComicWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.release,
        heroBuilder: buildComicReleaseInspectorHero,
        sectionsBuilder: buildComicReleaseInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
        heroBuilder: buildComicCopyInspectorHero,
        sectionsBuilder: buildComicCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
  personalDetailFieldsBuilder: buildComicPersonalDetailFields,
);

final comicKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<ComicMedia>(
  comicLinkedMetadata,
  comicLinkedMetadataValues,
);

final comicKindRelations = comicRelationCapability;

final comicKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: comicTransferableFieldKeys,
  kindFields: [
    ...comicUniversalTransferableFields,
    ...comicTransferableFieldDefinitions,
  ],
);

final comicKindStats = const ComicStatsCapability();

final comicKindValue = const ComicValueCapability();
