import '../book_module_dependencies.dart';
import '../entries/book_transfer_library_entry.dart';

final bookKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryTargetEditRegistry(
      catalogItem: buildBookLibraryEditDialog,
      libraryEntry: buildBookLibraryEditDialog),
  vocabularies: StandardKindVocabularyCapability(BookVocabularies.all),
  presentation: const LibraryEditPresentation(
    builder: BookCatalogItemEditPresentationBuilder(),
    catalogItemBuilder: BookCatalogItemEditPresentationBuilder(),
    sharedTabs: [
      LibraryEditTabContribution(
        tab: LibraryEditTabSpec(
          id: 'custom',
          icon: Icons.edit_note,
          label: 'Custom Fields',
          sectionIds: ['book_custom_fields'],
        ),
        afterTabId: 'credits',
      ),
      LibraryEditTabContribution(
        tab: LibraryEditTabSpec(
          id: 'links',
          icon: Icons.public,
          label: 'Links',
          sectionIds: ['book_identifiers_links'],
        ),
        afterTabId: 'plot',
      ),
    ],
  ),
  conditions: BookVocabularies.condition.builtIns,
  entryCollectionValueReader: (libraryEntry) => switch (libraryEntry?.value) {
    BookLibraryEntry item => item.personal.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  createSession: createBookEditDraft,
  entryDigitalFlagResolver: resolveBookEntryDigitalFlag,
  entryFormatHintResolver: resolveBookEntryFormatHint,
  entryIndexUpdatePayloadBuilder: (_, indexNumber) =>
      BookLibraryEntryUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  entryConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      BookLibraryEntryUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  entryBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          BookLibraryEntryUpdatePayload.partial(
    condition:
        condition == null ? const Patch.unchanged() : Patch.set(condition),
    grade: collectionValue == null
        ? const Patch.unchanged()
        : Patch.set(collectionValue),
    locationId:
        locationId == null ? const Patch.unchanged() : Patch.set(locationId),
    tags: tags == null ? const Patch.unchanged() : Patch.set(tags),
  ),
  entryPersonalDetailsUpdatePayloadBuilder: (
    _,
    purchaseDate,
    pricePaidCents,
    currency,
    personalNotes,
    purchaseStore,
    locationChanged,
    locationId,
  ) =>
      BookLibraryEntryUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  entryTransferUpdatePayloadBuilder: (_, updated) {
    final typed = bookTransferLibraryEntry(updated);
    return BookLibraryEntryUpdatePayload.partial(
      condition: Patch.set(typed.personal.condition),
      grade: Patch.set(typed.personal.grade),
      personalNotes: Patch.set(typed.personal.personalNotes),
      locationId: Patch.set(typed.personal.locationId),
      tags: Patch.set(typed.personal.tags),
      currency: Patch.set(typed.personal.currency),
      soldTo: Patch.set(typed.personal.soldTo),
      purchaseStore: Patch.set(typed.personal.purchaseStore),
      pricePaidCents: Patch.set(typed.personal.pricePaidCents),
      sellPriceCents: Patch.set(typed.personal.sellPriceCents),
      indexNumber: Patch.set(typed.personal.indexNumber),
      purchaseDate: Patch.set(typed.personal.purchaseDate),
      soldAt: Patch.set(typed.personal.soldAt),
      details: Patch.set(
        const BookEntryDetailsCodec().draftFromDetails(
          typed.personal.details,
        ),
      ),
    );
  },
  entryDetailsResetPayloadBuilder: () =>
      BookLibraryEntryUpdatePayload.partial(details: const Patch.clear()),
);
