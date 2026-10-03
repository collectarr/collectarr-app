import '../game_module_dependencies.dart';
import '../entries/game_transfer_library_entry.dart';

final gameKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.catalogItem,
      builder: buildGameLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.libraryEntry,
      builder: buildGameLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(GameVocabularies.all),
  conditions: GameVocabularies.condition.builtIns,
  entryCollectionValueReader: (libraryEntry) => switch (libraryEntry?.value) {
    GameLibraryEntry item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  presentation: gameLibraryEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  createSession: createGameEditDraft,
  entryDigitalFlagResolver: resolveGameEntryDigitalFlag,
  entryFormatHintResolver: resolveGameEntryFormatHint,
  entryIndexUpdatePayloadBuilder: (_, indexNumber) =>
      GameLibraryEntryUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  entryConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      GameLibraryEntryUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  entryBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          GameLibraryEntryUpdatePayload.partial(
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
      GameLibraryEntryUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  entryTransferUpdatePayloadBuilder: (_, updated) {
    final typed = gameTransferLibraryEntry(updated);
    return GameLibraryEntryUpdatePayload.partial(
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
        const GameEntryDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  entryDetailsResetPayloadBuilder: () =>
      GameLibraryEntryUpdatePayload.partial(details: const Patch.clear()),
);

Iterable<String> getGameFacetValues(
  GameWorkspaceDto dto,
  LibraryFacetIdRuntime facetId,
) {
  for (final definition in gameLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}
