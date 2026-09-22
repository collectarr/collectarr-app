import 'book_module_dependencies.dart';
import 'book_kind_components_support.dart';

final bookKindAdd = StandardLibraryAddCapability<BookAddDraft>(
  kind: CatalogMediaKind.book,
  initialDraftBuilder: BookAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      bookCatalogTransportFromTypedCandidate(
          candidate as BookProviderCandidate),
  coreCatalogProjectionBuilder: bookCatalogTransportFromCoreItem,
  manualDraftBuilder: BookAddManualDraft.new,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      BookOwnedItemCreatePayload(
    catalogRef: item.catalogRef,
    details: details as BookOwnedDetailsDraft,
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
    advancedFilterDescriptorsBuilder: buildBookAddAdvancedFilterFields,
    coreSearchInputBuilder: _buildBookCoreSearchInput,
    providerQueryBuilder: _buildBookProviderQuery,
    typedProviderSearchBuilder: searchBookProviderCandidates,
    typedProviderCandidatePreviewLoader: loadBookProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: bookAuthorFilterId,
          exactWeight: 110,
          containsWeight: 44,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is BookCatalogMetadata
                ? metadata.authors
                : const <Object?>[];
          },
          typedProviderValues: (candidate) => candidate is BookProviderCandidate
              ? [candidate.summary]
              : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: bookIsbnFilterId,
          exactWeight: 90,
          containsWeight: 30,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is BookCatalogMetadata
                ? [metadata.barcode, metadata.itemNumber]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) => candidate is BookProviderCandidate
              ? [candidate.providerItemId]
              : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: bookPublisherFilterId,
          exactWeight: 60,
          containsWeight: 24,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is BookCatalogMetadata
                ? [metadata.publisher, metadata.originalPublisher]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) => candidate is BookProviderCandidate
              ? [candidate.publisher]
              : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: bookYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is BookCatalogMetadata
                ? [metadata.originalPublicationDate?.year]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) => candidate is BookProviderCandidate
              ? [candidate.series?.volumeStartYear]
              : const <Object?>[],
        ),
      ],
    ),
  ),
  manualPaneBuilder: buildBookAddManualPane,
);

final bookKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildBookLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildBookReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildBookMediaLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(BookVocabularies.all),
  presentation: const LibraryEditPresentation(
    builder: BookLibraryMediaEditPresentationBuilder(),
    workBuilder: BookLibraryMediaEditPresentationBuilder(),
    releaseBuilder: BookLibraryReleaseEditPresentationBuilder(),
  ),
  conditions: BookVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    BookOwnedItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  createSession: createBookEditDraft,
  ownedDigitalFlagResolver: resolveBookOwnedDigitalFlag,
  ownedFormatHintResolver: resolveBookOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      BookOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      BookOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          BookOwnedItemUpdatePayload.partial(
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
      BookOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = bookTransferOwnedItem(updated);
    return BookOwnedItemUpdatePayload.partial(
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
        const BookOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      BookOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

Future<List<LibraryHierarchyNode>> _fetchBookVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final work =
      await api.getBookWorkDto(itemId).timeout(const Duration(seconds: 60));
  final book = BookCoreMapper.fromWorkDto(work);
  return BookHierarchyMapper.toLibraryNodes(book.editions);
}

String bookChildrenTitle(int count) => 'Editions ($count)';

Iterable<String> _getBookFacetValues(
  BookWorkspaceDto dto,
  LibraryFacetIdRuntime facetId,
) {
  for (final definition in bookLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}

List<LibraryAddAdvancedFilterField<String>> buildBookAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: bookAuthorFilterId,
        key: const ValueKey('library-add-author-field'),
        label: 'Author',
        value: req.advancedFilterText(bookAuthorFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: bookIsbnFilterId,
        key: const ValueKey('library-add-isbn-field'),
        label: 'ISBN',
        value: req.advancedFilterText(bookIsbnFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: bookPublisherFilterId,
        key: const ValueKey('library-add-publisher-field'),
        label: 'Publisher',
        value: req.advancedFilterText(bookPublisherFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: bookYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(bookYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery _buildBookCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  final author = context.textValueFor(bookAuthorFilterId);
  final isbn = context.textValueFor(bookIsbnFilterId);
  return MetadataSearchQuery(
    query:
        _optionalBookText(buildLibraryAddSearchQuery([context.query, author])),
    publisher: _optionalBookText(
      context.textValueFor(bookPublisherFilterId),
    ),
    year: int.tryParse(context.textValueFor(bookYearFilterId)),
    barcode: _optionalBookText(isbn.isNotEmpty ? isbn : context.identifierCode),
    limit: limit,
  );
}

String _buildBookProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(bookAuthorFilterId),
    context.textValueFor(bookIsbnFilterId),
    context.textValueFor(bookPublisherFilterId),
    context.textValueFor(bookYearFilterId),
    context.identifierCode,
  ]);
}

String? _optionalBookText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
