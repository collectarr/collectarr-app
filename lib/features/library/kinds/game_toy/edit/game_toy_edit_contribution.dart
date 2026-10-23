import '../game_toy_module_dependencies.dart';

final gameToyKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryTargetEditRegistry(
      catalogItem: buildGameToyItemEditDialog,
      libraryEntry: buildGameToyItemEditDialog),
  vocabularies: StandardKindVocabularyCapability(GameToyVocabularies.all),
  conditions: GameToyVocabularies.condition.builtIns,
  entryCollectionValueReader: (libraryEntry) => switch (libraryEntry?.value) {
    GameToyLibraryEntry item => item.personal.grade,
    _ => null,
  },
  // The reference leaves Condition empty on new games.
  defaultCondition: '',
  defaultCollectionValue: 'Ungraded',
  presentation: gameToyTypedEditPresentation,
  entryDigitalFlagResolver: resolveGameToyEntryDigitalFlag,
  entryFormatHintResolver: resolveGameToyEntryFormatHint,
  entryIndexUpdatePayloadBuilder: (_, indexNumber) =>
      GameToyLibraryEntryUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  entryConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      GameToyLibraryEntryUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  entryBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          GameToyLibraryEntryUpdatePayload.partial(
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
      GameToyLibraryEntryUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  entryTransferUpdatePayloadBuilder: (_, updated) {
    final typed = gameToyTransferLibraryEntry(updated);
    return GameToyLibraryEntryUpdatePayload.partial(
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
        const GameToyEntryDetailsCodec().draftFromDetails(
          typed.personal.details,
        ),
      ),
    );
  },
  entryDetailsResetPayloadBuilder: () =>
      GameToyLibraryEntryUpdatePayload.partial(details: const Patch.clear()),
);
