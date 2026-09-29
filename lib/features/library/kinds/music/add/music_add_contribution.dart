import '../music_module_dependencies.dart';
import '../config/music_kind_configuration.dart';
import '../edit/music_edit_contribution.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_catalog_remote_source.dart';

final musicKindAdd = StandardLibraryAddCapability<MusicAddDraft>(
  kind: CatalogMediaKind.music,
  initialDraftBuilder: MusicAddDraft.new,
  coreCatalogProjectionBuilder: musicCatalogTransportFromCoreItem,
  manualDraftBuilder: MusicAddManualDraft.new,
  manualCandidateBuilder: buildMusicManualCandidate,
  manualProposalBuilder: buildMusicManualProposalData,
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
          ),
        ],
      ),
    ),
    presentation: LibraryAddSearchPresentationCapability(
      controlsBuilder: buildMusicAddSearchControls,
    ),
  ),
  resultPolicy: musicAddResultPolicy,
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
  final transport = CatalogItemDto.fromJson(item.toSearchJson());
  final album = MusicCatalogMapper.mapMetadataItemToMusic(transport);
  final release = album.primaryRelease;
  if (release == null) return const <LibraryHierarchyNode>[];
  return MusicHierarchyMapper.toLibraryNodes(release);
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
