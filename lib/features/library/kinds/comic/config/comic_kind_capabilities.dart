import 'package:collectarr_app/ui/app_icons.dart';
import '../comic_module_dependencies.dart';
import 'comic_kind_configuration.dart';
import '../data/comic_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

final comicKindPresentation = comicLibraryCatalogItemPresentation;

final comicKindPhysicalMediaFormats = comicPhysicalMediaFormats;

final comicKindTrackingProfile = comicTrackingProfile;

final comicKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.comic,
  comicKindUiPolicy,
  cardLayout: LibraryWorkspaceCardLayout.headlined,
);

// The reference's comic covers are 148 x 207.
final comicKindUiPolicy = const LibraryUiPolicy(coverAspectRatio: 148 / 207);

final comicKindSearchTargetOptions = const <LibrarySearchTarget>[];

final comicKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.comic,
  singularLabel: 'Comic',
  pluralLabel: 'Comics',
  title: 'Comics',
  // A speech balloon, the medium's own sign.
  icon: Icons.mode_comment,
  coverPlaceholderIcon: AppIcons.bookOpen,
  accent: Color(0xFF00AEE6),
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
  catalogItem: LibraryTargetLabel(singular: 'Comic', plural: 'Comics'),
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
      switch (field.key) {
        'location_id' => relabelPersonalLibraryField(field, 'Storage Box'),
        'collection_status' =>
          relabelPersonalLibraryField(field, 'Collection Status'),
        _ => field,
      },
    const PersonalLibraryFieldSpec(
        key: 'quantity',
        label: 'Quantity',
        group: 'Collection state',
        syncable: true,
        inputKind: PersonalLibraryFieldEditor.integer,
        area: PersonalLibraryFieldArea.statusStrip,
        editOrder: 2,
        minimum: 0,
        defaultInteger: 1),
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
  showsActionBar: false,
  // The reference details show no My Images section.
  supportsLibraryEntryImages: false,
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
