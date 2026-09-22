import '../manga_module_dependencies.dart';
import '../manga_kind_components_support.dart';

final mangaKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildMangaLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildMangaReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildMangaMediaLibraryEditDialog,
    ),
  ]),
  presentation: mangaLibraryEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: MangaVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    MangaOwnedItem item => item.grade,
    _ => null,
  },
  vocabularies: StandardKindVocabularyCapability(MangaVocabularies.all),
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  editChrome: const LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    synopsisLabel: 'Plot',
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  createSession: createMangaEditDraft,
  ownedDigitalFlagResolver: resolveMangaOwnedDigitalFlag,
  ownedFormatHintResolver: resolveMangaOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      MangaOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      MangaOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          MangaOwnedItemUpdatePayload.partial(
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
      MangaOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = mangaTransferOwnedItem(updated);
    return MangaOwnedItemUpdatePayload.partial(
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
        const MangaOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      MangaOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);

Iterable<String> getFacetValues(
    MangaWorkspaceDto dto, LibraryFacetIdRuntime facetId) {
  for (final definition in mangaLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}
