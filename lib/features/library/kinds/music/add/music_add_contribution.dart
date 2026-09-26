import '../music_module_dependencies.dart';
import '../config/music_kind_configuration.dart';
import '../edit/music_edit_contribution.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';

final musicKindAdd = StandardLibraryAddCapability<MusicAddDraft>(
  kind: CatalogMediaKind.music,
  initialDraftBuilder: MusicAddDraft.new,
  typedProviderCandidateProjectionBuilder:
      musicCatalogTransportFromTypedProviderCandidate,
  coreCatalogProjectionBuilder: musicCatalogTransportFromCoreItem,
  manualDraftBuilder: MusicAddManualDraft.new,
  manualCandidateBuilder: buildMusicManualCandidate,
  manualCandidateValidationMessage: 'Enter a valid music release',
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      MusicOwnedItemCreatePayload(
    catalogRef: item.reference,
    releaseRef: musicPrimaryReleaseRef(item),
    details: details as MusicOwnedDetailsDraft,
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
  mediaTargetRefBuilder: musicPrimaryReleaseRef,
  digitalCopyFlagBuilder: (item) {
    final group = item.kindCapability
        .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
    final format =
        group.primaryRelease?.mediums.firstOrNull?.mediumType?.toLowerCase();
    return format == null
        ? null
        : const {'digital', 'download', 'streaming', 'file'}
            .any(format.contains);
  },
  search: LibraryAddSearchCapability(
    input: LibraryAddSearchInputCapability(
      initialAdvancedFilters: {
        musicAddMediumFilterId:
            LibraryAddOptionFilterValue(MusicAddMediumFilter.all.value),
      },
      advancedFilterDescriptorsBuilder: buildMusicAddAdvancedFilterFields,
      searchInputPredicate: musicAddHasSearchInput,
    ),
    core: LibraryAddCoreSearchCapability(
      inputBuilder: buildMusicCoreSearchInput,
      resultFilter: (items, context) => [
        for (final item in items)
          if (musicAddCoreCandidateMatchesMedium(item, context)) item,
      ],
    ),
    provider: LibraryAddProviderSearchCapability(
      queryBuilder: buildMusicProviderQuery,
      ranking: buildLibraryAddSearchRanking(
        fields: [
          LibraryAddSearchRankField(
            id: musicArtistFilterId,
            exactWeight: 120,
            containsWeight: 48,
            metadataValues: (item) {
              final group = item.kindCapability
                  .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
              return [group.artist];
            },
            typedProviderValues: (candidate) => [
              if (candidate case final MusicReleaseCandidate release)
                release.artist,
            ],
          ),
          LibraryAddSearchRankField(
            id: musicLabelFilterId,
            exactWeight: 60,
            containsWeight: 24,
            metadataValues: (item) {
              final group = item.kindCapability
                  .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
              return [group.primaryRelease?.publisher];
            },
            typedProviderValues: (candidate) => [
              if (candidate case final MusicReleaseCandidate release)
                release.publisher,
            ],
          ),
          LibraryAddSearchRankField(
            id: musicYearFilterId,
            exactWeight: 55,
            containsWeight: 20,
            metadataValues: (item) {
              final group = item.kindCapability
                  .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
              return [
                group.originalReleaseDate?.year,
                group.recordingDate?.year,
              ];
            },
            typedProviderValues: (candidate) => [
              if (candidate case final MusicReleaseCandidate release)
                release.releaseDate?.year,
            ],
          ),
        ],
      ),
      strategy: LibraryAddContextualProviderSearchStrategy(
          searchMusicProviderCandidatesWithContext),
      candidatePreviewLoader: loadMusicProviderCandidatePreview,
    ),
    presentation: LibraryAddSearchPresentationCapability(
      controlsBuilder: buildMusicAddSearchControls,
    ),
  ),
  resultPolicy: musicAddResultPolicy,
  manualPaneBuilder: buildMusicAddManualPane,
  chrome: musicAddChrome,
);

String musicChildrenTitle(int count) => 'Discs and tracks ($count)';

Future<List<LibraryHierarchyNode>> fetchMusicTracks({
  required ApiClient api,
  required String itemId,
  String? provider,
  String? providerItemId,
}) async {
  final dto = await api
      .getCatalogItem(CatalogItemRef(kind: CatalogMediaKind.music, id: itemId))
      .timeout(const Duration(seconds: 60));
  final album = MusicCoreMapper.fromCatalogItemV1(dto);
  return MusicHierarchyMapper.toAlbumLibraryNodes(album);
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

String buildMusicProviderQuery(LibraryAddSearchContext context) {
  return buildLibraryAddSearchQuery([
    context.query,
    context.textValueFor(musicArtistFilterId),
    context.textValueFor(musicLabelFilterId),
    context.textValueFor(musicYearFilterId),
    context.identifierCode,
    musicAddProviderMediumQuery(context),
  ]);
}

String? optionalMusicText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
