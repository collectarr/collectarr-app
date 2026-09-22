import '../comic_module_dependencies.dart';
import '../config/comic_kind_configuration.dart';

final comicKindAdd = StandardLibraryAddCapability<ComicAddDraft>(
  kind: CatalogMediaKind.comic,
  dialogLauncher: showComicLibraryAddDialog,
  initialDraftBuilder: ComicAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      comicCatalogTransportFromTypedCandidate(
    candidate as ComicProviderCandidate,
  ),
  coreCatalogProjectionBuilder: comicCatalogTransportFromCoreItem,
  manualDraftBuilder: ComicAddManualDraft.new,
  manualPaneBuilder: buildComicAddManualPane,
  headerBuilder: buildComicAddHeader,
  modeBarBuilder: buildComicAddModeBar,
  previewPaneBuilder: buildComicAddPreviewPane,
  searchPaneBuilder: buildComicAddSearchPane,
  bottomBarBuilder: buildComicAddBottomBar,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      ComicOwnedItemCreatePayload(
    catalogRef: item.catalogRef,
    details: details as ComicOwnedDetailsDraft,
    condition: common.condition,
    grade: kindValue ?? draft.grade,
    purchaseDate: common.purchaseDate,
    pricePaidCents: common.pricePaidCents,
    currency: common.currency,
    personalNotes: common.personalNotes,
    quantity: common.quantity,
    tags: common.tags,
    locationId: common.locationId,
    purchaseStore: common.purchaseStore,
    collectionStatus: common.collectionStatus,
    isDigital: common.isDigital,
  ),
  digitalCopyFlagBuilder: (item) {
    final payload = item.mapTransport((transport) => transport).payload;
    final direct = payload['is_digital'];
    if (direct is bool) return direct;
    final format =
        (payload['physical_format'] ?? payload['physical_format_label'])
            ?.toString()
            .toLowerCase();
    if (format == 'digital' || format == 'ebook' || format == 'web') {
      return true;
    }
    final series = payload['series'];
    if (series is Map && series['is_digital'] is bool) {
      return series['is_digital'] as bool;
    }
    final publishing = payload['publishing'];
    if (publishing is Map && publishing['is_digital'] is bool) {
      return publishing['is_digital'] as bool;
    }
    return null;
  },
  search: LibraryAddSearchCapability(
    advancedFilterDescriptorsBuilder: buildComicAddAdvancedFilterFields,
    coreSearchInputBuilder: buildComicCoreSearchInput,
    providerQueryBuilder: buildComicProviderQuery,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: comicSeriesFilterId,
          exactWeight: 120,
          containsWeight: 48,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is ComicMedia
                ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                : const [];
          },
          typedProviderValues: (candidate) =>
              candidate is ComicProviderCandidate
                  ? [candidate.series?.seriesTitle]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: comicIssueFilterId,
          exactWeight: 75,
          containsWeight: 36,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is ComicMedia ? [metadata.issueNumber] : const [];
          },
          typedProviderValues: (candidate) =>
              candidate is ComicProviderCandidate
                  ? [candidate.issueNumber]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: comicPublisherFilterId,
          exactWeight: 60,
          containsWeight: 24,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is ComicMedia
                ? [metadata.publisher, metadata.imprint]
                : const [];
          },
          typedProviderValues: (candidate) =>
              candidate is ComicProviderCandidate
                  ? [candidate.publisher]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: comicYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is ComicMedia
                ? [
                    metadata.releaseDate?.year,
                    metadata.coverDate?.year,
                    metadata.series?.volumeStartYear,
                  ]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is ComicProviderCandidate
                  ? [candidate.series?.volumeStartYear]
                  : const <Object?>[],
        ),
      ],
    ),
    coverScanQueryBuilder: comicCoverScanQuery,
    coverScanFilterValuesBuilder: comicCoverScanFilterValues,
    typedProviderSearchBuilder: searchComicProvider,
    typedProviderCandidatePreviewLoader: loadComicProviderCandidatePreview,
  ),
  resultPolicy: comicAddResultPolicy,
);

final comicKindToolbar = LibraryKindToolbarModule(
  actions: [
    ComicJumpToIssueAction(),
    ComicMissingIssuesAction(),
  ],
);

final class ComicJumpToIssueAction
    implements UiAction<LibraryToolbarActionContext> {
  const ComicJumpToIssueAction();

  @override
  String get id => 'comic.jump_to_issue';

  @override
  String get label => 'Jump to issue...';

  @override
  IconData get icon => Icons.tag_outlined;

  @override
  UiActionPlacement get placement => UiActionPlacement.secondary;

  @override
  bool isVisible(LibraryToolbarActionContext context) =>
      context.projection != null;

  @override
  bool isEnabled(LibraryToolbarActionContext context) =>
      context.projection != null && context.onJumpToNumberSubmitted != null;

  @override
  Future<void> run(LibraryToolbarActionContext context) async {
    final onSubmitted = context.onJumpToNumberSubmitted;
    if (onSubmitted == null || context.projection == null) return;
    await _showJumpToIssueDialog(
      context.buildContext,
      onSubmitted: onSubmitted,
    );
  }
}

final class ComicMissingIssuesAction
    implements UiAction<LibraryToolbarActionContext> {
  const ComicMissingIssuesAction();

  @override
  String get id => 'comic.missing_issues';

  @override
  String get label => 'Missing issues report...';

  @override
  IconData get icon => Icons.find_in_page_outlined;

  @override
  UiActionPlacement get placement => UiActionPlacement.secondary;

  @override
  bool isVisible(LibraryToolbarActionContext context) =>
      context.projection != null;

  @override
  bool isEnabled(LibraryToolbarActionContext context) =>
      context.projection != null && context.onMissingSequenceReport != null;

  @override
  Future<void> run(LibraryToolbarActionContext context) async {
    final projection = context.projection;
    if (projection == null) return;
    context.onMissingSequenceReport?.call(projection);
  }
}

String comicChildrenTitle(int count) => 'Volumes ($count)';

Future<List<LibraryHierarchyNode>> fetchComicVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final work =
      await api.getComicWorkDto(itemId).timeout(const Duration(seconds: 60));
  return ComicHierarchyMapper.toLibraryNodes(
    ComicCoreMapper.fromWorkDto(work),
  );
}

Iterable<String> getComicFacetValues(
    ComicWorkspaceDto dto, LibraryFacetIdRuntime facetId) {
  for (final definition in comicLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}

Future<List<Map<String, dynamic>>> loadComicFacetRows({
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

List<LibraryAddAdvancedFilterField<String>> buildComicAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: comicSeriesFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Series',
        value: req.advancedFilterText(comicSeriesFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: comicIssueFilterId,
        key: const ValueKey('library-add-number-field'),
        label: 'Issue',
        value: req.advancedFilterText(comicIssueFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: comicPublisherFilterId,
        key: const ValueKey('library-add-publisher-field'),
        label: 'Publisher',
        value: req.advancedFilterText(comicPublisherFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: comicYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(comicYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery buildComicCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: optionalText(context.query),
    series: optionalFilterText(context, comicSeriesFilterId),
    issueNumber: optionalFilterText(context, comicIssueFilterId),
    publisher: optionalFilterText(context, comicPublisherFilterId),
    year: int.tryParse(context.textValueFor(comicYearFilterId)),
    barcode: optionalText(context.identifierCode),
    limit: limit,
  );
}

String buildComicProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(comicSeriesFilterId),
    context.textValueFor(comicIssueFilterId),
    context.textValueFor(comicPublisherFilterId),
    context.textValueFor(comicYearFilterId),
    context.identifierCode,
  ]);
}

Map<LibraryAddFilterId, Object?> comicCoverScanFilterValues(
  LibraryCoverScanResult result,
) {
  final hints = parseComicCoverScanHints(result);
  return {
    if (hints.series?.trim().isNotEmpty == true)
      comicSeriesFilterId: hints.series!.trim(),
    if (hints.issueNumber?.trim().isNotEmpty == true)
      comicIssueFilterId: hints.issueNumber!.trim(),
    if (hints.publisher?.trim().isNotEmpty == true)
      comicPublisherFilterId: hints.publisher!.trim(),
    if (hints.year != null) comicYearFilterId: hints.year.toString(),
  };
}

String? comicCoverScanQuery(LibraryCoverScanResult result) {
  final hints = parseComicCoverScanHints(result);
  return hints.series?.trim().isNotEmpty == true
      ? hints.series!.trim()
      : result.query;
}

String? optionalText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? optionalFilterText(
  LibraryAddSearchContext context,
  LibraryAddFilterId id,
) {
  return optionalText(context.textValueFor(id));
}
