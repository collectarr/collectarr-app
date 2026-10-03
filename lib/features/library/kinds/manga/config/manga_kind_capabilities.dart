import '../manga_module_dependencies.dart';
import 'manga_kind_configuration.dart';

final mangaKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.manga,
  fields: [
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
  ],
);

final mangaKindPresentation = mangaLibraryMediaPresentation;

final mangaKindPhysicalMediaFormats = mangaPhysicalMediaFormats;

final mangaKindTrackingProfile = mangaTrackingProfile;

final mangaKindUiPolicy = const LibraryUiPolicy();

final LibraryRelationCapability? mangaKindRelations = null;

final LibraryValueCapability? mangaKindValue = null;

final mangaKindToolbar = null;

final mangaKindSearchTargetOptions = const <LibrarySearchTarget>[];

final mangaKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.manga,
  const LibraryUiPolicy(),
);

final mangaKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.manga,
  singularLabel: 'Manga',
  pluralLabel: 'Manga',
  title: 'Manga',
  icon: Icons.import_contacts_outlined,
  accent: Color(0xFFFF6F91),
  preferencePrefix: 'manga',
  routeSegments: ['manga'],
  mediaFamily: 'print',
  toolbarActions: [
    ...kDefaultLibraryToolbarActions,
    LibraryToolbarActionId.reassignIndex,
  ],
);

final mangaKindMetadata = LibraryMetadataCapability(
  catalogMetadataDecoder: MangaMetadata.fromJson,
  searchQueryBuilder: mangaMetadataSearchQuery,
);

final mangaKindHierarchy = const LibraryHierarchyCapability();

final mangaKindEntityVocabulary = const LibraryEntityVocabulary(
  catalogItem:
      LibraryEntityLabel(singular: 'Catalog Item', plural: 'Catalog Items'),
  libraryEntry: LibraryEntityLabel(singular: 'Entry', plural: 'Entries'),
);

final mangaKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTargetScope.content},
  aggregateTargets: {LibraryTrackingTargetScope.catalogItem},
  contentTargets: {LibraryTrackingTargetScope.content},
);

final mangaKindActions = const LibraryEntityActionCapability(
  catalogItem: LibraryEntityActionSet.catalogItem,
  libraryEntry: LibraryEntityActionSet.libraryEntry,
);

final mangaKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.catalogItem,
        heroBuilder: buildMangaWorkInspectorHero,
        sectionsBuilder: buildMangaWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.libraryEntry,
        heroBuilder: buildMangaCopyInspectorHero,
        sectionsBuilder: buildMangaCopyInspectorSections,
      ),
    ],
  ),
  showsDefaultPersonalSection: false,
);

final mangaKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<MangaMetadata>(
  mangaLinkedMetadata,
  mangaLinkedMetadataValues,
);

final mangaKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in mangaTransferableFields) field.key,
  ],
  kindFields: [
    ...mangaUniversalTransferableFields,
    ...mangaTransferableFields,
  ],
);

final mangaKindStats = const MangaStatsCapability();
