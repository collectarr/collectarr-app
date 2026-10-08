import '../manga_module_dependencies.dart';
import 'manga_kind_configuration.dart';
import '../data/manga_catalog_transport_codec.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

final mangaKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.manga,
  fields: [
    ...commonPersonalLibraryFields,
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
  catalogTransportCodec: MangaCatalogTransportCodec(),
  searchQueryBuilder: mangaMetadataSearchQuery,
);

final mangaKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem:
      LibraryTargetLabel(singular: 'Catalog Item', plural: 'Catalog Items'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final mangaKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTarget.content},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
  contentTargets: {LibraryTrackingTarget.content},
);

final mangaKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
);

final mangaKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildMangaCatalogItemInspectorHero,
      sectionsBuilder: buildMangaCatalogItemInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildMangaLibraryEntryInspectorHero,
      sectionsBuilder: buildMangaLibraryEntryInspectorSections,
    ),
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
