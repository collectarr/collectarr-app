import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_preview.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_shell.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_pane.dart';
import 'package:collectarr_app/features/library/kinds/comic/add_dialog.dart';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_card_presentation.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_hero.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_utility_menu.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/features/library/add/library_add_ranking.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/add/services/library_cover_scan_service.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_cache_workflow.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_provider_search.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/media/comic_media_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_dialog.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/relations/comic_relation_capability.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';

import 'package:collectarr_app/features/library/kinds/comic/stats/comic_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/comic/value/comic_value_capability.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';

const _comicSeriesFilterId = LibraryAddFilterId('comic.series');
const _comicIssueFilterId = LibraryAddFilterId('comic.issue');
const _comicPublisherFilterId = LibraryAddFilterId('comic.publisher');
const _comicYearFilterId = LibraryAddFilterId('comic.year');

String? _comicHierarchyContractDiagnosticLabel(LibraryProjectionRuntime item) {
  final dto = item.dto;
  if (dto is! ComicWorkspaceDto) {
    return null;
  }
  if (dto.seriesTitle?.trim().isNotEmpty != true) {
    return 'Missing series title';
  }
  if (item.node.scope != LibraryBrowserScope.title &&
      dto.variant?.trim().isNotEmpty != true) {
    return 'Missing release variant';
  }
  return null;
}

const _comicTransferableFieldKeys = <String>[
  ...kDefaultTransferableFieldKeys,
  'rawOrSlabbed',
  'gradingCompany',
  'graderNotes',
  'signedBy',
  'keyReason',
  'keyComic',
  'coverPriceCents',
];

final _comicTransferableFields = <TransferableField>[
  TransferableField(
    key: 'rawOrSlabbed',
    label: 'Raw / Slabbed',
    icon: Icons.layers_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.rawOrSlabbed,
    write: (item, value) {
      final details = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: details.copyWith(rawOrSlabbed: value));
    },
  ),
  TransferableField(
    key: 'gradingCompany',
    label: 'Grading company',
    icon: Icons.verified_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.gradingCompany,
    write: (item, value) {
      final details = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: details.copyWith(gradingCompany: value));
    },
  ),
  TransferableField(
    key: 'graderNotes',
    label: 'Grader notes',
    icon: Icons.note_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.graderNotes,
    write: (item, value) {
      final details = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: details.copyWith(graderNotes: value));
    },
  ),
  TransferableField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.signedBy,
    write: (item, value) {
      final details = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: details.copyWith(signedBy: value));
    },
  ),
  TransferableField(
    key: 'keyReason',
    label: 'Key reason',
    icon: Icons.vpn_key_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.comicDetails?.keyReason,
    write: (item, value) {
      final details = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(details: details.copyWith(keyReason: value));
    },
  ),
  TransferableField(
    key: 'keyComic',
    label: 'Key issue',
    icon: Icons.vpn_key,
    type: TransferableFieldType.boolean,
    read: (item) => (item.comicDetails?.keyComic == true) ? 'true' : null,
    write: (item, value) {
      final details = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(
          details: details.copyWith(keyComic: value == 'true'));
    },
  ),
  TransferableField(
    key: 'coverPriceCents',
    label: 'Cover price',
    icon: Icons.price_check,
    type: TransferableFieldType.integer,
    scope: LibraryEditScope.release,
    read: (item) => item.comicDetails?.coverPriceCents?.toString(),
    write: (item, value) {
      final details = item.comicDetails ?? const ComicOwnedDetails();
      return item.copyWith(
        details: details.copyWith(
          coverPriceCents: value != null ? int.tryParse(value) : null,
        ),
      );
    },
  ),
];

Iterable<String?> _comicLinkedMetadataValues(ComicCatalogMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.issueNumber,
      metadata.publisher,
      metadata.publishing?.originalPublisher,
      metadata.variant,
      metadata.imprint,
      metadata.publishing?.imprint,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

final comicKindModule = LibraryKindSpec<ComicWorkspaceDto, ComicOwnedDetails>(
  presentation: comicLibraryMediaPresentation,
  trackingProfile: comicTrackingProfile,
  viewProfile: comicsWorkspaceViewProfile,
  projector: const ComicWorkspaceProjector(),
  ownedDetailsCodec: const ComicOwnedDetailsCodec(),
  fields: comicLibraryKindSchema.toRegistry(),
  catalogCodec: const DefaultCatalogKindCodec<ComicCatalogMetadata>(
    ComicCatalogMetadata.fromJson,
    _encodeComicMetadata,
  ),
  identity: const LibraryKindIdentity(
    kind: CatalogMediaKind.comic,
    singularLabel: 'Comic',
    pluralLabel: 'Comics',
    title: 'Comics',
    icon: Icons.collections_bookmark_outlined,
    accent: Color(0xFF44BFE7),
    preferencePrefix: 'comics',
    toolbarActions: [
      ...kDefaultLibraryToolbarActions,
      LibraryToolbarActionId.readingQueue,
      LibraryToolbarActionId.reassignIndex,
    ],
  ),
  metadata: LibraryMetadataCapability(
    defaultProviderId: 'gcd',
    supportsServerCompare: true,
    usesTreeProviderCandidates: true,
    providers: [
      gcdMetadataProvider,
      comicVineMetadataProvider,
      mangadexMetadataProvider,
      anilistMetadataProvider,
      hardcoverMetadataProvider,
    ],
  ),
  hierarchy: const LibraryHierarchyCapability(
    fetchChildrenCallback: _fetchComicVolumes,
    childrenTitleBuilder: _comicChildrenTitle,
    supportsMediaReleaseSplit: false,
    contractDiagnosticLabelBuilder: _comicHierarchyContractDiagnosticLabel,
  ),
  inspector: const LibraryInspectorCapability(
    heroBuilder: buildComicInspectorHero,
    sectionsBuilder: buildComicInspectorSections,
    showsDefaultPersonalSection: false,
  ),
  linkedMetadata: TypedLibraryLinkedMetadataCapability<ComicCatalogMetadata>(
    _comicLinkedMetadataValues,
  ),
  relations: comicRelationCapability,
  transfer: LibraryTransferCapability(
    transferableFieldKeys: _comicTransferableFieldKeys,
    kindFields: _comicTransferableFields,
  ),
  stats: const ComicStatsCapability(),
  value: const ComicValueCapability(),
  add: StandardLibraryAddCapability<ComicAddDraft>(
    kind: CatalogMediaKind.comic,
    dialogLauncher: showComicLibraryAddDialog,
    initialDraftBuilder: ComicAddDraft.new,
    manualDraftBuilder: ComicAddManualDraft.new,
    manualPaneBuilder: buildComicAddManualPane,
    headerBuilder: buildComicAddHeader,
    modeBarBuilder: buildComicAddModeBar,
    previewPaneBuilder: buildComicAddPreviewPane,
    searchPaneBuilder: buildComicAddSearchPane,
    bottomBarBuilder: buildComicAddBottomBar,
    search: LibraryAddSearchCapability(
      advancedFilterDescriptorsBuilder: buildComicAddAdvancedFilterFields,
      coreSearchInputBuilder: _buildComicCoreSearchInput,
      providerQueryBuilder: _buildComicProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: _comicSeriesFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is ComicCatalogMetadata
                  ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                  : const [];
            },
            providerValues: (candidate) => [candidate.series?.seriesTitle],
          ),
          LibraryAddSearchRankField(
            id: _comicIssueFilterId,
            exactWeight: 75,
            containsWeight: 36,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is ComicCatalogMetadata
                  ? [metadata.issueNumber]
                  : const [];
            },
            providerValues: (candidate) => [candidate.issueNumber],
          ),
          LibraryAddSearchRankField(
            id: _comicPublisherFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is ComicCatalogMetadata
                  ? [metadata.publisher, metadata.imprint]
                  : const [];
            },
            providerValues: (candidate) => [candidate.publisher],
          ),
          LibraryAddSearchRankField(
            id: _comicYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindMetadata;
              return metadata is ComicCatalogMetadata
                  ? [
                      metadata.releaseDate?.year,
                      metadata.coverDate?.year,
                      metadata.series?.volumeStartYear,
                    ]
                  : const <Object?>[];
            },
            providerValues: (candidate) => [candidate.series?.volumeStartYear],
          ),
        ],
      ),
      coverScanQueryBuilder: (result) => result.query ?? result.series,
      coverScanFilterValuesBuilder: _comicCoverScanFilterValues,
      providerSearchBuilder: searchComicProvider,
    ),
    resultPolicy: comicAddResultPolicy,
  ),
  edit: LibraryEditCapability(
    editDialogBuilder: buildComicLibraryEditDialog,
    mediaEditDialogBuilder: buildComicMediaLibraryEditDialog,
    releaseEditDialogBuilder: buildComicReleaseLibraryEditDialog,
    vocabularies: StandardKindVocabularyCapability(ComicVocabularies.all),
    presentation: comicsLibraryEditPresentation,
    conditions: ComicVocabularies.condition.builtIns,
    grades: ComicVocabularies.grade.builtIns,
    defaultCondition: 'Near Mint',
    defaultGrade: 'Ungraded',
    editChrome: const LibraryEditChromeConfig(
      titleUsesItemTitle: true,
      synopsisLabel: 'Plot',
      showsIssueBadge: true,
      showsPhysicalFormatBadge: true,
    ),
    createDraft: createComicEditDraft,
  ),
  toolbar: LibraryKindToolbarModule(
    actions: [
      LibraryToolbarActionDescriptor(
        id: 'comic.jump_to_issue',
        label: 'Jump to issue...',
        icon: Icons.tag_outlined,
        section: 'Collection',
        buildAction: (buildContext, context) {
          return LibraryUtilityMenuAction(
            icon: Icons.tag_outlined,
            label: 'Jump to issue...',
            section: 'Collection',
            enabled: context.projection != null &&
                context.onJumpToNumberSubmitted != null,
            onSelected: context.projection == null ||
                    context.onJumpToNumberSubmitted == null
                ? null
                : () => _showJumpToIssueDialog(
                      buildContext,
                      onSubmitted: context.onJumpToNumberSubmitted!,
                    ),
          );
        },
      ),
      LibraryToolbarActionDescriptor(
        id: 'comic.missing_issues',
        label: 'Missing issues report...',
        icon: Icons.find_in_page_outlined,
        section: 'Collection',
        buildAction: (buildContext, context) {
          final projection = context.projection;
          return LibraryUtilityMenuAction(
            icon: Icons.find_in_page_outlined,
            label: 'Missing issues report...',
            section: 'Collection',
            enabled: projection != null,
            onSelected: projection == null
                ? null
                : () => context.onMissingSequenceReport?.call(projection),
          );
        },
      ),
    ],
  ),
  providerMapper: const ComicLibraryKindProviderMapper(),
  facets: LibraryFacetModule(
    loadRows: _loadComicFacetRows,
    getFacetValues: _getFacetValues,
    definitions: comicLibraryFacetDefinitions,
    externalFacetBucketIdsByMode: {
      'comic.story_arc': ComicFacetIds.storyArc,
      'comic.character': ComicFacetIds.character,
    },
  ),
  buildCardPresentation: buildComicCardPresentation,
);

String _comicChildrenTitle(int count) => 'Volumes ($count)';

Future<List<LibraryHierarchyNode>> _fetchComicVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final volumes = await api
      .getItemVolumes(itemId, kind: CatalogMediaKind.comic.apiValue)
      .timeout(const Duration(seconds: 60));
  return [
    for (final volume in volumes)
      LibraryHierarchyNode(
        id: 'volume_${volume.seasonNumber}',
        label: volume.title,
        secondaryLabel:
            volume.episodeCount != null ? '${volume.episodeCount} items' : null,
        level: LibraryHierarchyLevel.container,
        imageUrl: volume.posterUrl,
        totalCount: volume.episodeCount,
        metadata: {
          'number': volume.seasonNumber,
          'airDate': volume.airDate,
        },
      ),
  ];
}

Iterable<String> _getFacetValues(
    LibraryProjectionRuntime item, LibraryFacetIdRuntime facetId) {
  final dto = item.dto;
  if (dto is! ComicWorkspaceDto) {
    return const [];
  }
  for (final definition in comicLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}

Future<List<Map<String, dynamic>>> _loadComicFacetRows({
  required LibraryFacetIdRuntime facetId,
  required Set<String> itemIds,
  required ApiClient api,
}) {
  if (facetId == ComicFacetIds.storyArc) {
    return api.storyArcFacets(itemIds);
  }
  if (facetId == ComicFacetIds.character) {
    return api.characterFacets(itemIds);
  }
  return Future.value(const <Map<String, dynamic>>[]);
}

Future<void> _showJumpToIssueDialog(
  BuildContext context, {
  required void Function(String value) onSubmitted,
}) async {
  final controller = TextEditingController();
  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        void submit() {
          final value = controller.text.trim();
          if (value.isEmpty) {
            return;
          }
          Navigator.of(dialogContext).pop();
          onSubmitted(value);
        }

        return AlertDialog(
          title: const Text('Jump to issue'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Issue #',
            ),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submit,
              child: const Text('Jump'),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}

Map<String, dynamic> _encodeComicMetadata(ComicCatalogMetadata m) => m.toJson();

List<LibraryAddAdvancedFilterField<String>> buildComicAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: _comicSeriesFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Series',
        value: req.advancedFilterText(_comicSeriesFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _comicIssueFilterId,
        key: const ValueKey('library-add-number-field'),
        label: 'Issue',
        value: req.advancedFilterText(_comicIssueFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _comicPublisherFilterId,
        key: const ValueKey('library-add-publisher-field'),
        label: 'Publisher',
        value: req.advancedFilterText(_comicPublisherFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: _comicYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(_comicYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

LibraryMetadataSearchInput _buildComicCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return LibraryMetadataSearchInput(
    query: _optionalText(context.query),
    series: _optionalFilterText(context, _comicSeriesFilterId),
    issueNumber: _optionalFilterText(context, _comicIssueFilterId),
    publisher: _optionalFilterText(context, _comicPublisherFilterId),
    year: int.tryParse(context.textValueFor(_comicYearFilterId)),
    barcode: _optionalText(context.barcode),
    limit: limit,
  );
}

String _buildComicProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(_comicSeriesFilterId),
    context.textValueFor(_comicIssueFilterId),
    context.textValueFor(_comicPublisherFilterId),
    context.textValueFor(_comicYearFilterId),
    context.barcode,
  ]);
}

Map<LibraryAddFilterId, Object?> _comicCoverScanFilterValues(
  LibraryCoverScanResult result,
) {
  return {
    if (result.series?.trim().isNotEmpty == true)
      _comicSeriesFilterId: result.series!.trim(),
    if (result.issueNumber?.trim().isNotEmpty == true)
      _comicIssueFilterId: result.issueNumber!.trim(),
    if (result.publisher?.trim().isNotEmpty == true)
      _comicPublisherFilterId: result.publisher!.trim(),
    if (result.year != null) _comicYearFilterId: result.year.toString(),
  };
}

String? _optionalText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _optionalFilterText(
  LibraryAddSearchContext context,
  LibraryAddFilterId id,
) {
  return _optionalText(context.textValueFor(id));
}
