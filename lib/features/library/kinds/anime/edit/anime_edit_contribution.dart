import '../anime_module_dependencies.dart';
import '../anime_kind_components_support.dart';

final animeKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildAnimeLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildAnimeReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildAnimeMediaLibraryEditDialog,
    ),
  ]),
  presentation: animeLibraryEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: AnimeVocabularies.condition.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    AnimeOwnedItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  vocabularies: StandardKindVocabularyCapability(AnimeVocabularies.all),
  createSession: createAnimeEditDraft,
  ownedDigitalFlagResolver: resolveAnimeOwnedDigitalFlag,
  ownedFormatHintResolver: resolveAnimeOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      AnimeOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      AnimeOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          AnimeOwnedItemUpdatePayload.partial(
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
      AnimeOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = animeTransferOwnedItem(updated);
    return AnimeOwnedItemUpdatePayload.partial(
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
        const AnimeOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      AnimeOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);
