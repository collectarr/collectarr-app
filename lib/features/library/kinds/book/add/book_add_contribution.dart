import '../book_module_dependencies.dart';
import '../config/book_kind_configuration.dart';
import 'book_manual_candidate.dart';

final bookKindAdd = StandardLibraryAddCapability<BookAddDraft>(
  kind: CatalogMediaKind.book,
  initialDraftBuilder: BookAddDraft.new,
  coreCatalogProjectionBuilder: bookCatalogTransportFromCoreItem,
  manualDraftBuilder: BookAddManualDraft.new,
  manualCandidateBuilder: buildBookManualCandidate,
  manualProposalBuilder: buildBookManualProposalData,
  entryPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      BookLibraryEntryCreatePayload(
    details: details as BookEntryDetailsDraft,
    condition: common.condition,
    grade: kindValue ?? draft.grade,
    purchaseDate: common.purchaseDate,
    pricePaidCents: common.pricePaidCents,
    currency: common.currency,
    personalNotes: common.personalNotes,
    tags: common.tags,
    locationId: common.locationId,
    purchaseStore: common.purchaseStore,
    ownerLabel: common.ownerLabel,
    collectionStatus: common.collectionStatus,
    isDigital: common.isDigital,
  ),
  digitalCopyFlagBuilder: (item) {
    final metadata = item.kindCapability.mapTransport(
      (transport) => BookCatalogMetadata.fromJson(transport.kindData),
    );
    final format = metadata.physicalFormat?.toLowerCase();
    if (format == 'digital' || format == 'ebook' || format == 'web') {
      return true;
    }
    return null;
  },
  search: LibraryAddSearchCapability(
    input: LibraryAddSearchInputCapability(
      advancedFilterDescriptorsBuilder: buildBookAddAdvancedFilterFields,
    ),
    core: LibraryAddCoreSearchCapability(
      inputBuilder: _buildBookCoreSearchInput,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: bookAuthorFilterId,
            exactWeight: 110,
            containsWeight: 44,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport((transport) =>
                  BookCatalogMetadata.fromJson(transport.kindData));
              return metadata.authors;
            },
          ),
          LibraryAddSearchRankField(
            id: bookIsbnFilterId,
            exactWeight: 90,
            containsWeight: 30,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport((transport) =>
                  BookCatalogMetadata.fromJson(transport.kindData));
              return [metadata.barcode, metadata.itemNumber];
            },
          ),
          LibraryAddSearchRankField(
            id: bookPublisherFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport((transport) =>
                  BookCatalogMetadata.fromJson(transport.kindData));
              return [metadata.publisher];
            },
          ),
          LibraryAddSearchRankField(
            id: bookYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport((transport) =>
                  BookCatalogMetadata.fromJson(transport.kindData));
              return [metadata.releaseDate?.year];
            },
          ),
        ],
      ),
    ),
  ),
  manualPaneBuilder: buildBookAddManualPane,
);

Iterable<String> getBookFacetValues(
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

String? _optionalBookText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
