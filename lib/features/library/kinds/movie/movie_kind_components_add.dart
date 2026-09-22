import 'movie_module_dependencies.dart';
import 'movie_kind_components_support.dart';

final movieKindAdd = StandardLibraryAddCapability<MovieAddDraft>(
  kind: CatalogMediaKind.movie,
  dialogLauncher: showMovieLibraryAddDialog,
  initialDraftBuilder: MovieAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      movieCatalogTransportFromTypedCandidate(
    candidate as MovieProviderCandidate,
  ),
  coreCatalogProjectionBuilder: movieCatalogTransportFromCoreItem,
  manualDraftBuilder: MovieAddManualDraft.new,
  manualPaneBuilder: buildMovieAddManualPane,
  chrome: movieAddChrome,
  headerBuilder: buildMovieAddHeader,
  modeBarBuilder: buildMovieAddModeBar,
  previewPaneBuilder: buildMovieAddPreviewPane,
  searchPaneBuilder: buildMovieAddSearchPane,
  bottomBarBuilder: buildMovieAddBottomBar,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      MovieOwnedItemCreatePayload(
    catalogRef: item.catalogRef,
    details: details as MovieOwnedDetailsDraft,
    condition: common.condition,
    grade: common.isDigital == true ? null : kindValue ?? draft.grade,
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
    initialAdvancedFilters: {
      libraryAddKindFilterId: {movieSearchScope},
    },
    advancedFilterDescriptorsBuilder: buildMovieAddAdvancedFilterFields,
    searchInputPredicate: libraryAddHasSearchInput,
    kindSpecificPaneBuilder: buildLibraryAddKindFilterRow,
    providerKindOverridesBuilder: (context) =>
        libraryAddKindOverridesForChrome(movieAddChrome, context),
    coreSearchInputBuilder: buildMovieCoreSearchInput,
    providerQueryBuilder: buildMovieProviderQuery,
    typedProviderSearchBuilder: searchMovieProviderCandidates,
    typedProviderCandidatePreviewLoader: loadMovieProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: movieCollectionFilterId,
          exactWeight: 110,
          containsWeight: 44,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MovieCatalogMetadata
                ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MovieProviderCandidate
                  ? [candidate.series?.seriesTitle]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: movieYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MovieCatalogMetadata
                ? [metadata.releaseDate?.year]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MovieProviderCandidate
                  ? [candidate.series?.volumeStartYear]
                  : const <Object?>[],
        ),
      ],
    ),
  ),
  resultPolicy: buildMovieAddResultPolicy(
    mediaLabel: 'Media',
    supportsSeasonScope: false,
    coreScopeForItem: movieAddResultScope,
    providerScopeForCandidate: movieAddProviderResultScope,
    coreGroupTitleBuilder: movieAddGroupTitle,
    providerCandidateIsGroup: movieAddProviderCandidateIsGroup,
  ),
);

final movieKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildMovieLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildMovieReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildMovieMediaLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(MovieVocabularies.all),
  presentation: movieLibraryEditPresentation,
  conditions: MovieVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    MovieOwnedItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  createSession: createMovieEditDraft,
  ownedDigitalFlagResolver: resolveMovieOwnedDigitalFlag,
  ownedFormatHintResolver: resolveMovieOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      MovieOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      MovieOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          MovieOwnedItemUpdatePayload.partial(
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
      MovieOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = movieTransferOwnedItem(updated);
    return MovieOwnedItemUpdatePayload.partial(
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
        const MovieOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      MovieOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

List<LibraryAddAdvancedFilterField<String>> buildMovieAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: movieCollectionFilterId,
        key: const ValueKey('library-add-collection-field'),
        label: 'Collection',
        value: req.advancedFilterText(movieCollectionFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: movieYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(movieYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery buildMovieCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: optionalMovieText(
      buildLibraryAddSearchQuery([
        context.query,
        context.textValueFor(movieCollectionFilterId),
      ]),
    ),
    year: int.tryParse(context.textValueFor(movieYearFilterId)),
    barcode: optionalMovieText(context.identifierCode),
    limit: limit,
  );
}

String buildMovieProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(movieCollectionFilterId),
    context.textValueFor(movieYearFilterId),
    context.identifierCode,
  ]);
}

String? optionalMovieText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

MovieAddResultScope movieAddResultScope(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  if (metadata is MovieCatalogMetadata &&
      [
        metadata.editionTitle,
        metadata.itemNumber,
        metadata.physicalFormat,
        metadata.physicalFormatLabel,
        metadata.barcode,
        metadata.variant,
      ].any((value) => value?.trim().isNotEmpty == true)) {
    return MovieAddResultScope.release;
  }
  return MovieAddResultScope.media;
}

MovieAddResultScope movieAddProviderResultScope(
  MovieProviderCandidate candidate,
) {
  if (candidate.searchRole.isCollectibleRelease) {
    return MovieAddResultScope.release;
  }
  return MovieAddResultScope.media;
}

String movieAddGroupTitle(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  if (metadata is MovieCatalogMetadata) {
    return metadata.seriesTitle?.trim() ??
        metadata.series?.seriesTitle?.trim() ??
        item.title;
  }
  return item.title;
}
