import '../anime_module_dependencies.dart';
import '../entries/anime_transfer_library_entry.dart';

final animeKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryTargetEditRegistry(catalogItem: buildAnimeLibraryEditDialog, libraryEntry: buildAnimeLibraryEditDialog),
  presentation: animeLibraryEditPresentation,
  conditions: AnimeVocabularies.condition.builtIns,
  entryCollectionValueReader: (libraryEntry) => switch (libraryEntry?.value) {
    AnimeLibraryEntry item => item.personal.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  vocabularies: StandardKindVocabularyCapability(AnimeVocabularies.all),
  createSession: createAnimeEditDraft,
  entryDigitalFlagResolver: resolveAnimeEntryDigitalFlag,
  entryFormatHintResolver: resolveAnimeEntryFormatHint,
  entryIndexUpdatePayloadBuilder: (_, indexNumber) =>
      AnimeLibraryEntryUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  entryConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      AnimeLibraryEntryUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  entryBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          AnimeLibraryEntryUpdatePayload.partial(
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
      AnimeLibraryEntryUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  entryTransferUpdatePayloadBuilder: (_, updated) {
    final typed = animeTransferLibraryEntry(updated);
    return AnimeLibraryEntryUpdatePayload.partial(
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
        const AnimeEntryDetailsCodec().draftFromDetails(
          typed.personal.details,
        ),
      ),
    );
  },
  entryDetailsResetPayloadBuilder: () =>
      AnimeLibraryEntryUpdatePayload.partial(details: const Patch.clear()),
);
