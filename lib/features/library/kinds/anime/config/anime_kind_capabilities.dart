import '../anime_module_dependencies.dart';
import 'anime_kind_configuration.dart';
import '../add/anime_add_contribution.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/metadata/common_personal_library_fields.dart';

final animeKindPersonalFieldContributor = const LibraryPersonalFieldContributor(
  kind: CatalogMediaKind.anime,
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

final animeKindPresentation = animeLibraryMediaPresentation;

final animeKindPhysicalMediaFormats = animePhysicalMediaFormats;

final animeKindTrackingProfile = animeTrackingProfile;

final LibraryRelationCapability? animeKindRelations = null;

final LibraryValueCapability? animeKindValue = null;

final animeKindToolbar = null;

final animeKindSearchTargetOptions = const <LibrarySearchTarget>[];

final animeKindViewProfile = standardMediaWorkspaceViewProfile(
  CatalogMediaKind.anime,
  const LibraryUiPolicy(),
);

final animeKindIdentity = const LibraryKindIdentity(
  kind: CatalogMediaKind.anime,
  singularLabel: 'Anime',
  pluralLabel: 'Anime',
  title: 'Anime',
  icon: Icons.movie_filter_outlined,
  accent: Color(0xFFC94DFF),
  preferencePrefix: 'anime',
  routeSegments: ['anime'],
  mediaFamily: 'video',
);

final animeKindMetadata = const LibraryMetadataCapability(
  catalogMetadataDecoder: AnimeMetadata.fromJson,
  searchQueryBuilder: animeMetadataSearchQuery,
);

final animeKindHierarchy = const LibraryHierarchyCapability(
  fetchChildrenCallback: fetchAnimeEpisodes,
  childrenTitleBuilder: animeChildrenTitle,
);

final animeKindEntityVocabulary = const LibraryTargetVocabulary(
  catalogItem:
      LibraryTargetLabel(singular: 'Catalog Item', plural: 'Catalog Items'),
  libraryEntry: LibraryTargetLabel(singular: 'Entry', plural: 'Entries'),
);

final animeKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.watch,
  writableTargets: {LibraryTrackingTarget.content},
  aggregateTargets: {LibraryTrackingTarget.libraryEntry},
  contentTargets: {LibraryTrackingTarget.content},
);

final animeKindActions = const LibraryTargetActionCapability(
  catalogItem: LibraryTargetActionSet.catalogItem,
  libraryEntry: LibraryTargetActionSet.libraryEntry,
);

final animeKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryTargetInspectorRegistry(
    catalogItem: LibraryTargetInspectorContributor(
      heroBuilder: buildAnimeCatalogItemInspectorHero,
      sectionsBuilder: buildAnimeCatalogItemInspectorSections,
    ),
    libraryEntry: LibraryTargetInspectorContributor(
      heroBuilder: buildAnimeLibraryEntryInspectorHero,
      sectionsBuilder: buildAnimeLibraryEntryInspectorSections,
    ),
  ),
  showsDefaultPersonalSection: false,
  trackingEditor: LibraryTrackingEditorCapability(
    builder: buildAnimeTrackingEditorExtension,
  ),
);

final animeKindLinkedMetadata =
    TypedLibraryLinkedMetadataCapability<AnimeMetadata>(
  animeLinkedMetadata,
  animeLinkedMetadataValues,
);

final animeKindTransfer = LibraryTransferCapability(
  transferableFieldKeys: [
    ...kDefaultTransferableFieldKeys,
    for (final field in animeTransferableFields) field.key,
  ],
  kindFields: [
    ...animeUniversalTransferableFields,
    ...animeTransferableFields,
  ],
);

final animeKindStats = const AnimeStatsCapability();

final animeKindUiPolicy = const LibraryUiPolicy(
  wideDialog: true,
);
