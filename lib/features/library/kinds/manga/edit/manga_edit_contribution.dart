import '../manga_module_dependencies.dart';
import '../ownership/manga_transfer_collection_item.dart';

final mangaKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.catalogItem,
      builder: buildMangaLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.collectionItem,
      builder: buildMangaLibraryEditDialog,
    ),
  ]),
  presentation: mangaLibraryEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: MangaVocabularies.condition.builtIns,
  ownedCollectionValueReader: (collectionItem) => switch (collectionItem?.value) {
    MangaCollectionItem item => item.grade,
    _ => null,
  },
  vocabularies: StandardKindVocabularyCapability(MangaVocabularies.all),
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  editChrome: const LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  createSession: createMangaEditDraft,
  ownedDigitalFlagResolver: resolveMangaOwnedDigitalFlag,
  ownedFormatHintResolver: resolveMangaOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      MangaCollectionItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      MangaCollectionItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          MangaCollectionItemUpdatePayload.partial(
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
      MangaCollectionItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = mangaTransferCollectionItem(updated);
    return MangaCollectionItemUpdatePayload.partial(
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
      MangaCollectionItemUpdatePayload.partial(details: const Patch.clear()),
);

Iterable<String> getMangaFacetValues(
    MangaWorkspaceDto dto, LibraryFacetIdRuntime facetId) {
  for (final definition in mangaLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}
