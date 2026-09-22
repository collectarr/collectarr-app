import 'manga_module_dependencies.dart';
import 'manga_kind_components_support.dart';
import 'package:collectarr_app/features/library/kinds/manga/release/manga_release_projection_capability.dart'
    as manga_release;

final mangaKindPresentation = mangaLibraryMediaPresentation;

final mangaKindPhysicalMediaFormats = mangaPhysicalMediaFormats;

final mangaKindTrackingProfile = mangaTrackingProfile;

final mangaKindWorkCapability = const DefaultWorkProjectionCapability();

final mangaKindReleaseCapability = manga_release.mangaKindReleaseCapability;

final mangaKindReleaseDetailSource = manga_release.mangaKindReleaseDetailSource;

final mangaKindCatalogTarget = const MangaCatalogTargetCapability();

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
  defaultProviderId: 'hardcover',
  catalogMetadataDecoder: MangaMetadata.fromJson,
  searchQueryBuilder: mangaMetadataSearchQuery,
  usesTreeProviderCandidates: true,
  providers: [
    hardcoverMetadataProvider,
    comicVineMetadataProvider,
    anilistMetadataProvider,
    mangadexMetadataProvider,
  ],
);

final mangaKindHierarchy = const LibraryHierarchyCapability(
  fetchChildrenCallback: fetchMangaVolumes,
  childrenTitleBuilder: mangaChildrenTitle,
  contractDiagnosticLabelBuilder: mangaHierarchyContractDiagnosticLabel,
);

final mangaKindEntityVocabulary = const LibraryEntityVocabulary(
  work: LibraryEntityLabel(singular: 'Volume', plural: 'Volumes'),
  release: LibraryEntityLabel(singular: 'Edition', plural: 'Editions'),
  copy: LibraryEntityLabel(singular: 'Copy', plural: 'Copies'),
);

final mangaKindTrackingTopology = const LibraryTrackingTopology(
  sessionLabels: LibraryTrackingSessionLabels.read,
  writableTargets: {LibraryTrackingTargetScope.content},
  aggregateTargets: {LibraryTrackingTargetScope.work},
  contentTargets: {LibraryTrackingTargetScope.content},
);

final mangaKindActions = const LibraryEntityActionCapability(
  work: LibraryEntityActionSet.work,
  release: LibraryEntityActionSet.release,
  copy: LibraryEntityActionSet.copy,
);

final mangaKindInspector = LibraryInspectorCapability(
  entityRegistry: LibraryEntityInspectorRegistry(
    contributors: [
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.work,
        heroBuilder: buildMangaWorkInspectorHero,
        sectionsBuilder: buildMangaWorkInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.release,
        heroBuilder: buildMangaReleaseInspectorHero,
        sectionsBuilder: buildMangaReleaseInspectorSections,
      ),
      LibraryEntityInspectorContributor(
        scope: LibraryEntityScope.copy,
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
