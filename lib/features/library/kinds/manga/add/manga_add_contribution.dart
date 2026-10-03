import '../manga_module_dependencies.dart';
import '../config/manga_kind_configuration.dart';
import 'manga_manual_candidate.dart';

final mangaKindAdd = StandardLibraryAddCapability<MangaAddDraft>(
  kind: CatalogMediaKind.manga,
  initialDraftBuilder: MangaAddDraft.new,
  coreCatalogProjectionBuilder: mangaCatalogTransportFromCoreItem,
  manualDraftBuilder: MangaAddManualDraft.new,
  manualCandidateBuilder: buildMangaManualCandidate,
  manualProposalBuilder: buildMangaManualProposalData,
  entryPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      MangaLibraryEntryCreatePayload(
    details: details as MangaEntryDetailsDraft,
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
    final payload =
        item.kindCapability.mapTransport((transport) => transport).payload;
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
    input: LibraryAddSearchInputCapability(
      advancedFilterDescriptorsBuilder: buildMangaAddAdvancedFilterFields,
    ),
    core: LibraryAddCoreSearchCapability(
      inputBuilder: buildMangaCoreSearchInput,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: mangaSeriesFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport(
                  (transport) => MangaMetadata.fromJson(transport.kindData));
              return metadata is MangaMetadata
                  ? [metadata.seriesTitle, metadata.series?.seriesTitle]
                  : const <Object?>[];
            },
          ),
          LibraryAddSearchRankField(
            id: mangaVolumeFilterId,
            exactWeight: 75,
            containsWeight: 36,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport(
                  (transport) => MangaMetadata.fromJson(transport.kindData));
              return metadata is MangaMetadata
                  ? [metadata.itemNumber, metadata.volumeNumber]
                  : const <Object?>[];
            },
          ),
          LibraryAddSearchRankField(
            id: mangaPublisherFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport(
                  (transport) => MangaMetadata.fromJson(transport.kindData));
              return metadata is MangaMetadata
                  ? [
                      metadata.publisher,
                      metadata.originalPublisher,
                      metadata.localizedPublisher,
                    ]
                  : const <Object?>[];
            },
          ),
          LibraryAddSearchRankField(
            id: mangaYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final metadata = item.kindCapability.mapTransport(
                  (transport) => MangaMetadata.fromJson(transport.kindData));
              return metadata is MangaMetadata
                  ? [
                      metadata.originalPublicationDate?.year,
                      metadata.localizedReleaseDate?.year,
                    ]
                  : const <Object?>[];
            },
          ),
        ],
      ),
    ),
  ),
  manualPaneBuilder: buildMangaAddManualPane,
);

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

String? optionalMangaText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
