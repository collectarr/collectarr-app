import '../book_module_dependencies.dart';
import '../ownership/book_transfer_collection_item.dart';

final bookKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.catalogItem,
      builder: buildBookLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.collectionItem,
      builder: buildBookLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(BookVocabularies.all),
  presentation: const LibraryEditPresentation(
    builder: BookCatalogItemEditPresentationBuilder(),
    workBuilder: BookCatalogItemEditPresentationBuilder(),
  ),
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: BookVocabularies.condition.builtIns,
  ownedCollectionValueReader: (collectionItem) => switch (collectionItem?.value) {
    BookCollectionItem item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  createSession: createBookEditDraft,
  ownedDigitalFlagResolver: resolveBookOwnedDigitalFlag,
  ownedFormatHintResolver: resolveBookOwnedFormatHint,
  ownedIndexUpdatePayloadBuilder: (_, indexNumber) =>
      BookCollectionItemUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  ownedConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      BookCollectionItemUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  ownedBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          BookCollectionItemUpdatePayload.partial(
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
      BookCollectionItemUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  ownedTransferUpdatePayloadBuilder: (_, updated) {
    final typed = bookTransferCollectionItem(updated);
    return BookCollectionItemUpdatePayload.partial(
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
        const BookOwnedDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  ownedDetailsResetPayloadBuilder: () =>
      BookCollectionItemUpdatePayload.partial(details: const Patch.clear()),
);
