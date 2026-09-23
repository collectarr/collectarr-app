import '../comic_module_dependencies.dart';
import '../ownership/comic_transfer_owned_item.dart';

final comicKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.work,
      builder: buildComicLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.release,
      builder: buildComicReleaseLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.copy,
      builder: buildComicMediaLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(ComicVocabularies.all),
  presentation: comicsLibraryEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: ComicVocabularies.condition.builtIns,
  collectionValueOptions: ComicVocabularies.grade.builtIns,
  ownedCollectionValueReader: (ownedItem) => switch (ownedItem?.value) {
    ComicOwnedItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  editChrome: const LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  createSession: createComicEditDraft,
  ownedDigitalFlagResolver: resolveComicOwnedDigitalFlag,
  ownedFormatHintResolver: resolveComicOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      ComicOwnedItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      ComicOwnedItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          ComicOwnedItemUpdatePayload.partial(
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
      ComicOwnedItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = comicTransferOwnedItem(updated);
    return ComicOwnedItemUpdatePayload.partial(
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
        const ComicOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      ComicOwnedItemUpdatePayload.partial(details: const Patch.clear()),
);
