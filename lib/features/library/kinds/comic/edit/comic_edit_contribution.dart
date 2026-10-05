import '../comic_module_dependencies.dart';
import '../entries/comic_transfer_library_entry.dart';

final comicKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryTargetEditRegistry(catalogItem: buildComicLibraryEditDialog, libraryEntry: buildComicCatalogItemLibraryEditDialog),
  vocabularies: StandardKindVocabularyCapability(ComicVocabularies.all),
  presentation: comicsLibraryEditPresentation,
  conditions: ComicVocabularies.condition.builtIns,
  collectionValueOptions: ComicVocabularies.grade.builtIns,
  entryCollectionValueReader: (libraryEntry) => switch (libraryEntry?.value) {
    ComicLibraryEntry item => item.personal.grade,
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
  entryDigitalFlagResolver: resolveComicEntryDigitalFlag,
  entryFormatHintResolver: resolveComicEntryFormatHint,
  entryIndexUpdatePayloadBuilder: (_, indexNumber) =>
      ComicLibraryEntryUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  entryConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      ComicLibraryEntryUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  entryBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          ComicLibraryEntryUpdatePayload.partial(
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
      ComicLibraryEntryUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  entryTransferUpdatePayloadBuilder: (_, updated) {
    final typed = comicTransferLibraryEntry(updated);
    return ComicLibraryEntryUpdatePayload.partial(
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
        const ComicEntryDetailsCodec().draftFromDetails(
          typed.personal.details,
        ),
      ),
    );
  },
  entryDetailsResetPayloadBuilder: () =>
      ComicLibraryEntryUpdatePayload.partial(details: const Patch.clear()),
);
