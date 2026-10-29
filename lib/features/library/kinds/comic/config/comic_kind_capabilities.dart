import 'package:collectarr_app/ui/app_icons.dart';
import '../comic_module_dependencies.dart';
import 'comic_kind_configuration.dart';
import '../actions/comic_missing_issues_action.dart';
import '../data/comic_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

final comicKindPresentation = comicLibraryCatalogItemPresentation;

final comicKindPhysicalMediaFormats = comicPhysicalMediaFormats;

final comicKindTrackingProfile = comicTrackingProfile;

final comicKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.comic,
  comicKindUiPolicy,
);

final comicKindUiPolicy = const LibraryUiPolicy();

final comicKindSearchTargetOptions = const <LibrarySearchTarget>[];

final comicKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.comic,
  singularLabel: 'Comic',
  pluralLabel: 'Comics',
  title: 'Comics',
  icon: Icons.collections_bookmark_outlined,
  coverPlaceholderIcon: AppIcons.bookOpen,
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
  catalogTransportCodec: ComicCatalogTransportCodec(),
  searchQueryBuilder: comicMetadataSearchQuery,
  supportsServerCompare: true,
  compareBuilder: buildComicMetadataComparePanels,
);

// A Comic Catalog Item already represents one concrete issue or edition.
// There is no Work -> issue -> variant child tree to fetch.
final comicKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem: LibraryTargetLabel(singular: 'Issue', plural: 'Issues'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final comicKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTarget.content},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
  contentTargets: {LibraryTrackingTarget.content},
);

final comicKindPersonalFieldContributor = LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.comic,
  fields: [
    for (final field in commonPersonalLibraryFields)
      field.key == 'location_id'
          ? relabelPersonalLibraryField(field, 'Storage Box')
          : field,
    const PersonalLibraryFieldSpec(
      key: 'last_bag_board_date',
      label: 'Last bag/board date',
      group: 'Storage',
    ),
    const PersonalLibraryFieldSpec(
      key: 'cover_price_cents',
      label: 'Cover price',
      group: 'Acquisition',
    ),
    const PersonalLibraryFieldSpec(
      key: 'raw_or_slabbed',
      label: 'Raw or slabbed',
      group: 'Grading',
      syncable: true,
    ),
    const PersonalLibraryFieldSpec(
      key: 'grading_company',
      label: 'Grading company',
      group: 'Grading',
      syncable: true,
    ),
    const PersonalLibraryFieldSpec(
      key: 'grader_notes',
      label: 'Grader notes',
      group: 'Grading',
    ),
    const PersonalLibraryFieldSpec(
      key: 'signed_by',
      label: 'Signed by',
      group: 'Grading',
      syncable: true,
    ),
    const PersonalLibraryFieldSpec(
      key: 'label_type',
      label: 'Label type',
      group: 'Grading',
    ),
    const PersonalLibraryFieldSpec(
      key: 'custom_label',
      label: 'Custom label',
      group: 'Grading',
    ),
    const PersonalLibraryFieldSpec(
      key: 'page_quality',
      label: 'Page quality',
      group: 'Grading',
    ),
    const PersonalLibraryFieldSpec(
      key: 'certification_number',
      label: 'Certification number',
      group: 'Grading',
    ),
    const PersonalLibraryFieldSpec(
      key: 'keycomic',
      label: 'Key comic',
      group: 'Comic flags',
    ),
    const PersonalLibraryFieldSpec(
      key: 'key_reason',
      label: 'Key reason',
      group: 'Comic flags',
    ),
    const PersonalLibraryFieldSpec(
      key: 'key_category',
      label: 'Key category',
      group: 'Comic flags',
    ),
    const PersonalLibraryFieldSpec(
      key: 'key_severity',
      label: 'Key severity',
      group: 'Comic flags',
    ),
  ],
);

final comicKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
  catalogItemSemanticActions: [
    LibraryTargetSemanticActionDefinition(
      id: 'comic.missing_issues',
      label: 'Missing issues',
      icon: Icons.find_in_page_outlined,
      invoke: runComicMissingIssuesAction,
    ),
  ],
);

final comicKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildComicCatalogItemInspectorHero,
      sectionsBuilder: buildComicCatalogItemInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildComicLibraryEntryInspectorHero,
      sectionsBuilder: buildComicLibraryEntryInspectorSections,
    ),
  ),
  showsDefaultPersonalSection: false,
  personalDetailFieldsBuilder: buildComicPersonalDetailFields,
);

final comicKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<ComicCatalogItem>(
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
