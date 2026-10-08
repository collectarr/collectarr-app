import '../music_module_dependencies.dart';
import '../config/music_kind_configuration.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_catalog_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_catalog_item_hierarchy_mapper.dart';

final musicKindAdd = StandardLibraryAddCapability<MusicAddDraft>(
  kind: CatalogMediaKind.music,
  initialDraftBuilder: MusicAddDraft.new,
  coreCatalogProjectionBuilder: musicCatalogTransportFromCoreItem,
  manualDraftBuilder: MusicAddManualDraft.new,
  manualCandidateBuilder: buildMusicManualCandidate,
  manualProposalBuilder: buildMusicManualProposalData,
  manualCandidateValidationMessage: 'Enter a valid music album',
  entryPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      MusicLibraryEntryCreatePayload(
    details: details as MusicEntryDetailsDraft,
    initialListens: draft.initialListens,
    quantity: draft.quantity,
    condition: common.condition,
    rating: draft.rating,
    mediaCondition: draft.mediaCondition,
    purchaseDateParts: draft.purchaseDateParts,
    indexNumber: draft.indexNumber,
    marketValueCents: draft.marketValueCents,
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
    final format =
        musicCatalogItemFromCandidate(item).formatSummary?.toLowerCase();
    return format == null
        ? null
        : const {'digital', 'download', 'streaming', 'file'}
            .any(format.contains);
  },
  search: LibraryAddSearchCapability(
    input: LibraryAddSearchInputCapability(
      initialAdvancedFilters: {
        musicAddDiscFilterId:
            LibraryAddOptionFilterValue(MusicAddDiscFilter.all.value),
      },
      advancedFilterDescriptorsBuilder: buildMusicAddAdvancedFilterFields,
      searchInputPredicate: musicAddHasSearchInput,
    ),
    core: LibraryAddCoreSearchCapability(
      inputBuilder: buildMusicCoreSearchInput,
      resultFilter: (items, context) => [
        for (final item in items)
          if (musicAddCoreCandidateMatchesDisc(item, context)) item,
      ],
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: musicArtistFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              return [musicCatalogItemFromCandidate(item).artist];
            },
          ),
          LibraryAddSearchRankField(
            id: musicLabelFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              return [musicCatalogItemFromCandidate(item).publisher];
            },
          ),
          LibraryAddSearchRankField(
            id: musicYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final catalogItem = musicCatalogItemFromCandidate(item);
              return [
                catalogItem.releaseDateParts ?? catalogItem.releaseDate,
                catalogItem.originalReleaseDateParts ??
                    catalogItem.originalReleaseDate,
                catalogItem.recordingDateParts ?? catalogItem.recordingDate,
              ];
            },
          ),
        ],
      ),
    ),
    presentation: LibraryAddSearchPresentationCapability(
      controlsBuilder: buildMusicAddSearchControls,
    ),
  ),
  resultPolicy: const LibraryAddResultPolicy.identity(),
  manualPaneBuilder: buildMusicAddManualPane,
  chrome: musicAddChrome,
);

String musicChildrenTitle(int count) => 'Discs ($count)';

Future<List<LibraryHierarchyNode>> fetchMusicTracks({
  required ApiClient api,
  required String itemId,
}) async {
  final item = await MusicCatalogRemoteSource(api)
      .getById(itemId)
      .timeout(const Duration(seconds: 60));
  return MusicCatalogItemHierarchyMapper.toLibraryNodes(
    item,
    catalogItemId: itemId,
  );
}

List<LibraryAddAdvancedFilterField<String>> buildMusicAddAdvancedFilterFields(
  LibraryAddModeBarRequest req,
) =>
    [
      LibraryAddAdvancedFilterField<String>(
        id: musicArtistFilterId,
        key: const ValueKey('library-add-series-field'),
        label: 'Artist',
        value: req.advancedFilterText(musicArtistFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: musicLabelFilterId,
        key: const ValueKey('library-add-label-field'),
        label: 'Record Label',
        value: req.advancedFilterText(musicLabelFilterId),
        parse: (text) => text.trim(),
      ),
      LibraryAddAdvancedFilterField<String>(
        id: musicYearFilterId,
        key: const ValueKey('library-add-year-field'),
        label: 'Year',
        value: req.advancedFilterText(musicYearFilterId),
        parse: (text) => text.trim(),
        width: 120,
      ),
    ];

MetadataSearchQuery buildMusicCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: optionalMusicText(context.query),
    series: optionalMusicText(context.textValueFor(musicArtistFilterId)),
    publisher: optionalMusicText(context.textValueFor(musicLabelFilterId)),
    year: int.tryParse(context.textValueFor(musicYearFilterId)),
    barcode: optionalMusicText(context.identifierCode),
    limit: limit,
  );
}

String? optionalMusicText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
