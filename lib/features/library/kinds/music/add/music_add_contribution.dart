import '../music_module_dependencies.dart';
import '../config/music_kind_configuration.dart';
import '../edit/music_edit_contribution.dart';

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
              switch (candidate) {
                MusicReleaseCandidate release => release.artist,
                MusicReleaseGroupCandidate group => group.artist,
                _ => null,
              },
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
              switch (candidate) {
                MusicReleaseCandidate release => release.publisher,
                MusicReleaseGroupCandidate group => group.releases
                    .map((release) => release.publisher)
                    .whereType<String>()
                    .firstOrNull,
                _ => null,
              },
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
              switch (candidate) {
                MusicReleaseCandidate release => release.releaseDate?.year,
                MusicReleaseGroupCandidate group =>
                  group.originalReleaseDate?.year,
                _ => null,
              },
            ],
          ),
        ],
      ),
      strategy: LibraryAddContextualProviderSearchStrategy(
          searchMusicProviderCandidatesWithContext),
      candidatePreviewLoader: loadMusicProviderCandidatePreview,
      resultPolicy: LibraryAddProviderResultPolicy(
        filter: (candidates, context) => [
          for (final candidate in candidates)
            if (musicAddProviderCandidateMatchesMedium(candidate, context))
              candidate,
        ],
        hydrationPredicate: (context) =>
            musicAddProviderMediumQuery(context) == null &&
            context.identifierCode.trim().isEmpty,
        removeGroupsWithoutVisibleChildren: true,
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
  String? provider,
  String? providerItemId,
}) async {
  final groupDto = await api
      .getMusicReleaseGroupDto(itemId)
      .timeout(const Duration(seconds: 60));
  final group = MusicCoreMapper.fromReleaseGroupDto(groupDto);
  final summary = group.primaryRelease;
  if (summary == null) return const <LibraryHierarchyNode>[];
  final dto = await api
      .getMusicReleaseDto(summary.id.value)
      .timeout(const Duration(seconds: 60));
  final release = MusicCoreMapper.fromReleaseDto(dto);
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
