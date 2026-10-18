import '../music_module_dependencies.dart';
import 'music_add_preview.dart';
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
    autocapTitles: common.autocapTitles,
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
      searchInputPredicate: musicAddHasSearchInput,
      searchesCatalogNumber: true,
    ),
    core: LibraryAddCoreSearchCapability(
      inputBuilder: buildMusicCoreSearchInput,
      resultFilter: (items, context) => [
        for (final item in items)
          if (musicAddCoreCandidateMatchesDisc(item, context)) item,
      ],
      ranking: buildLibraryAddSearchRanking(fields: const []),
    ),
    presentation: LibraryAddSearchPresentationCapability(
      controlsBuilder: buildMusicAddSearchControls,
    ),
  ),
  resultPolicy: const LibraryAddResultPolicy.identity(),
  manualPaneBuilder: buildMusicAddManualPane,
  previewPaneBuilder: buildMusicAddPreview,
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

MetadataSearchQuery buildMusicCoreSearchInput(
  LibraryAddSearchContext context, {
  required int limit,
}) {
  return MetadataSearchQuery(
    query: optionalMusicText(context.query),
    barcode: optionalMusicText(context.identifierCode),
    catalogNumber: optionalMusicText(context.catalogNumber),
    limit: limit,
  );
}

String? optionalMusicText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
