import '../manga_module_dependencies.dart';
import '../config/manga_kind_configuration.dart';

final mangaKindAdd = StandardLibraryAddCapability<MangaAddDraft>(
  kind: CatalogMediaKind.manga,
  initialDraftBuilder: MangaAddDraft.new,
  typedProviderCandidateProjectionBuilder: (candidate) =>
      mangaCatalogTransportFromTypedCandidate(
    candidate as MangaProviderCandidate,
  ),
  coreCatalogProjectionBuilder: mangaCatalogTransportFromCoreItem,
  manualDraftBuilder: MangaAddManualDraft.new,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      MangaOwnedItemCreatePayload(
    catalogRef: item.catalogRef,
    details: details as MangaOwnedDetailsDraft,
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
    advancedFilterDescriptorsBuilder: buildMangaAddAdvancedFilterFields,
    coreSearchInputBuilder: buildMangaCoreSearchInput,
    providerQueryBuilder: buildMangaProviderQuery,
    typedProviderSearchBuilder: searchMangaProviderCandidates,
    typedProviderCandidatePreviewLoader: loadMangaProviderCandidatePreview,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: mangaSeriesFilterId,
          exactWeight: 120,
          containsWeight: 48,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MangaMetadata
                ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MangaProviderCandidate
                  ? [candidate.series?.seriesTitle]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: mangaVolumeFilterId,
          exactWeight: 75,
          containsWeight: 36,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MangaMetadata
                ? [metadata.itemNumber, metadata.volumeNumber]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MangaProviderCandidate
                  ? [candidate.issueNumber]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: mangaPublisherFilterId,
          exactWeight: 60,
          containsWeight: 24,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MangaMetadata
                ? [
                    metadata.publisher,
                    metadata.originalPublisher,
                    metadata.localizedPublisher,
                  ]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MangaProviderCandidate
                  ? [candidate.publisher]
                  : const <Object?>[],
        ),
        LibraryAddSearchRankField(
          id: mangaYearFilterId,
          exactWeight: 55,
          containsWeight: 20,
          metadataValues: (item) {
            final metadata =
                item.mapTransport((transport) => transport).kindMetadata;
            return metadata is MangaMetadata
                ? [
                    metadata.originalPublicationDate?.year,
                    metadata.localizedReleaseDate?.year,
                  ]
                : const <Object?>[];
          },
          typedProviderValues: (candidate) =>
              candidate is MangaProviderCandidate
                  ? [candidate.series?.volumeStartYear]
                  : const <Object?>[],
        ),
      ],
    ),
  ),
  manualPaneBuilder: buildMangaAddManualPane,
);

String mangaChildrenTitle(int count) => 'Volumes ($count)';

Future<List<LibraryHierarchyNode>> fetchMangaVolumes({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final work =
      await api.getMangaWorkDto(itemId).timeout(const Duration(seconds: 60));
  final manga = MangaCoreMapper.fromWorkDto(work);
  final hierarchy = MangaHierarchyMapper.fromChapterRows(
    seriesId: itemId,
    rows: manga.chapters.whereType<Map<Object?, Object?>>().map(
          (chapter) => Map<String, dynamic>.from(chapter),
        ),
  );
  return MangaHierarchyMapper.toLibraryNodes(hierarchy);
}

List<LibraryAddAdvancedFilterField<String>> buildMangaAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: mangaSeriesFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Series',
        value: req.advancedFilterText(mangaSeriesFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: mangaVolumeFilterId,
        key: const ValueKey('library-add-number-field'),
        label: 'Volume',
        value: req.advancedFilterText(mangaVolumeFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: mangaPublisherFilterId,
        key: const ValueKey('library-add-publisher-field'),
        label: 'Publisher',
        value: req.advancedFilterText(mangaPublisherFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: mangaYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(mangaYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery buildMangaCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: optionalMangaText(context.query),
    series: optionalMangaText(context.textValueFor(mangaSeriesFilterId)),
    issueNumber: optionalMangaText(context.textValueFor(mangaVolumeFilterId)),
    publisher: optionalMangaText(context.textValueFor(mangaPublisherFilterId)),
    year: int.tryParse(context.textValueFor(mangaYearFilterId)),
    barcode: optionalMangaText(context.identifierCode),
    limit: limit,
  );
}

String buildMangaProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(mangaSeriesFilterId),
    context.textValueFor(mangaVolumeFilterId),
    context.textValueFor(mangaPublisherFilterId),
    context.textValueFor(mangaYearFilterId),
    context.identifierCode,
  ]);
}

String? optionalMangaText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
