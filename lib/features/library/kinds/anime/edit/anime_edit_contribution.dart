import '../anime_module_dependencies.dart';
import '../ownership/anime_transfer_collection_item.dart';

final animeKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.catalogItem,
      builder: buildAnimeLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.collectionItem,
      builder: buildAnimeLibraryEditDialog,
    ),
  ]),
  presentation: animeLibraryEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: AnimeVocabularies.condition.builtIns,
  ownedCollectionValueReader: (collectionItem) => switch (collectionItem?.value) {
    AnimeCollectionItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  vocabularies: StandardKindVocabularyCapability(AnimeVocabularies.all),
  createSession: createAnimeEditDraft,
  ownedDigitalFlagResolver: resolveAnimeOwnedDigitalFlag,
  ownedFormatHintResolver: resolveAnimeOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      AnimeCollectionItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      AnimeCollectionItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          AnimeCollectionItemUpdatePayload.partial(
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
      AnimeCollectionItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = animeTransferCollectionItem(updated);
    return AnimeCollectionItemUpdatePayload.partial(
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
        const AnimeOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      AnimeCollectionItemUpdatePayload.partial(details: const Patch.clear()),
);
