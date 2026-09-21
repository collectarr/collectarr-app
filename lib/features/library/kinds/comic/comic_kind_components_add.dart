part of 'comic_kind_components.dart';

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
    coreSearchInputBuilder: _buildComicCoreSearchInput,
    providerQueryBuilder: _buildComicProviderQuery,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: _comicSeriesFilterId,
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
          id: _comicIssueFilterId,
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
          id: _comicPublisherFilterId,
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
          id: _comicYearFilterId,
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
    coverScanQueryBuilder: _comicCoverScanQuery,
    coverScanFilterValuesBuilder: _comicCoverScanFilterValues,
    typedProviderSearchBuilder: searchComicProvider,
    typedProviderCandidatePreviewLoader: loadComicProviderCandidatePreview,
  ),
  resultPolicy: comicAddResultPolicy,
);

final comicKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildComicLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildComicReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildComicMediaLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(ComicVocabularies.all),
  presentation: comicsLibraryEditPresentation,
  conditions: ComicVocabularies.condition.builtIns,
  collectionValueOptions: ComicVocabularies.grade.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    ComicOwnedItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  editChrome: const LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    synopsisLabel: 'Plot',
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  createSession: createComicEditDraft,
  ownedDigitalFlagResolver: resolveComicOwnedDigitalFlag,
  ownedFormatHintResolver: resolveComicOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      ComicOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      ComicOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          ComicOwnedItemUpdatePayload.partial(
    condition:
        condition == null ? const Patch.unchanged() : Patch.set(condition),
    grade: collectionValue == null
        ? const Patch.unchanged()
        : Patch.set(collectionValue),
    locationId:
        locationId == null ? const Patch.unchanged() : Patch.set(locationId),
    tags: tags == null ? const Patch.unchanged() : Patch.set(tags),
  ),
  ownedPersonalDetailsUpdatePayloadBuilder: (
    _,
    purchaseDate,
    pricePaidCents,
    currency,
    personalNotes,
    purchaseStore,
    locationChanged,
    locationId,
  ) =>
      ComicOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = _comicTransferOwnedItem(updated);
    return ComicOwnedItemUpdatePayload.partial(
      condition: Patch.set(typed.condition),
      grade: Patch.set(typed.grade),
      personalNotes: Patch.set(typed.personalNotes),
      locationId: Patch.set(typed.locationId),
      tags: Patch.set(typed.tags),
      currency: Patch.set(typed.currency),
      soldTo: Patch.set(typed.soldTo),
      purchaseStore: Patch.set(typed.purchaseStore),
      pricePaidCents: Patch.set(typed.pricePaidCents),
      sellPriceCents: Patch.set(typed.sellPriceCents),
      quantity: Patch.set(typed.quantity),
      indexNumber: Patch.set(typed.indexNumber),
      purchaseDate: Patch.set(typed.purchaseDate),
      soldAt: Patch.set(typed.soldAt),
      details: Patch.set(
        const ComicOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      ComicOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

final comicKindToolbar = LibraryKindToolbarModule(
  actions: [
    _ComicJumpToIssueAction(),
    _ComicMissingIssuesAction(),
  ],
);

final class _ComicJumpToIssueAction
    implements UiAction<LibraryToolbarActionContext> {
  const _ComicJumpToIssueAction();

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

final class _ComicMissingIssuesAction
    implements UiAction<LibraryToolbarActionContext> {
  const _ComicMissingIssuesAction();

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

String _comicChildrenTitle(int count) => 'Volumes ($count)';

Future<List<LibraryHierarchyNode>> _fetchComicVolumes({
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

Iterable<String> _getFacetValues(
    ComicWorkspaceDto dto, LibraryFacetIdRuntime facetId) {
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

MetadataSearchQuery _buildComicCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: _optionalText(context.query),
    series: _optionalFilterText(context, _comicSeriesFilterId),
    issueNumber: _optionalFilterText(context, _comicIssueFilterId),
    publisher: _optionalFilterText(context, _comicPublisherFilterId),
    year: int.tryParse(context.textValueFor(_comicYearFilterId)),
    barcode: _optionalText(context.identifierCode),
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
    context.identifierCode,
  ]);
}

Map<LibraryAddFilterId, Object?> _comicCoverScanFilterValues(
  LibraryCoverScanResult result,
) {
  final hints = parseComicCoverScanHints(result);
  return {
    if (hints.series?.trim().isNotEmpty == true)
      _comicSeriesFilterId: hints.series!.trim(),
    if (hints.issueNumber?.trim().isNotEmpty == true)
      _comicIssueFilterId: hints.issueNumber!.trim(),
    if (hints.publisher?.trim().isNotEmpty == true)
      _comicPublisherFilterId: hints.publisher!.trim(),
    if (hints.year != null) _comicYearFilterId: hints.year.toString(),
  };
}

String? _comicCoverScanQuery(LibraryCoverScanResult result) {
  final hints = parseComicCoverScanHints(result);
  return hints.series?.trim().isNotEmpty == true
      ? hints.series!.trim()
      : result.query;
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
