import 'music_module_dependencies.dart';
import 'music_kind_components_support.dart';

final musicKindAdd = StandardLibraryAddCapability<MusicAddDraft>(
  kind: CatalogMediaKind.music,
  initialDraftBuilder: MusicAddDraft.new,
  typedProviderCandidateProjectionBuilder:
      musicCatalogTransportFromTypedProviderCandidate,
  coreCatalogProjectionBuilder: musicCatalogTransportFromCoreItem,
  manualDraftBuilder: MusicAddManualDraft.new,
  manualCandidateBuilder: buildMusicManualCandidate,
  ownedPayloadBuilder: (item, common, draft, details, {kindValue}) =>
      MusicOwnedItemCreatePayload(
    catalogRef: item.catalogRef,
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
    final group = item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
    final format =
        group.primaryRelease?.mediums.firstOrNull?.mediumType?.toLowerCase();
    return format == null
        ? null
        : const {'digital', 'download', 'streaming', 'file'}
            .any(format.contains);
  },
  search: LibraryAddSearchCapability(
    initialAdvancedFilters: {
      musicAddSearchScopeFilterId: MusicAddSearchScope.releaseGroup.value,
      musicAddMediumFilterId: MusicAddMediumFilter.all.value,
    },
    advancedFilterDescriptorsBuilder: buildMusicAddAdvancedFilterFields,
    coreSearchInputBuilder: buildMusicCoreSearchInput,
    providerQueryBuilder: buildMusicProviderQuery,
    searchInputPredicate: musicAddHasSearchInput,
    typedProviderSearchBuilder: searchMusicProviderCandidates,
    typedProviderSearchContextBuilder: searchMusicProviderCandidatesWithContext,
    typedProviderCandidatePreviewLoader: loadMusicProviderCandidatePreview,
    coreSearchResultFilter: (items, context) => [
      for (final item in items)
        if (musicAddCoreCandidateMatchesMedium(item, context)) item,
    ],
    typedProviderSearchResultFilter: (candidates, context) => [
      for (final candidate in candidates)
        if (musicAddProviderCandidateMatchesMedium(candidate, context))
          candidate,
    ],
    providerGroupHydrationPredicate: (context) =>
        musicAddSearchScopeFor(context) == MusicAddSearchScope.releaseGroup &&
        context.identifierCode.trim().isEmpty,
    removeProviderGroupsWithoutVisibleChildren: true,
    kindSpecificPaneBuilder: buildMusicAddSearchControls,
    ranking: buildLibraryAddSearchRanking(
      fields: [
        LibraryAddSearchRankField(
          id: musicArtistFilterId,
          exactWeight: 120,
          containsWeight: 48,
          metadataValues: (item) {
            final group =
                item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
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
            final group =
                item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
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
            final group =
                item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
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
  ),
  resultPolicy: musicAddResultPolicy,
  manualPaneBuilder: buildMusicAddManualPane,
  chrome: musicAddChrome,
);

final musicKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildMusicReleaseGroupLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildMusicReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildMusicReleaseLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(MusicVocabularies.all),
  presentation: musicTypedEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: MusicVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    MusicOwnedItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  ownedDigitalFlagResolver: resolveMusicOwnedDigitalFlag,
  ownedFormatHintResolver: resolveMusicOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      MusicOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      MusicOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          MusicOwnedItemUpdatePayload.partial(
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
      MusicOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = musicTransferOwnedItem(updated);
    return MusicOwnedItemUpdatePayload.partial(
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
        const MusicOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      MusicOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

CatalogEntityRef musicPrimaryReleaseRef(CatalogSearchCandidate item) {
  final group = item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
  final release = group.primaryRelease;
  if (release == null) {
    throw StateError(
      'Music ownership requires a concrete release in the catalog result',
    );
  }
  return musicReleaseRefForRoot(item.catalogRef, release.id.value);
}

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
