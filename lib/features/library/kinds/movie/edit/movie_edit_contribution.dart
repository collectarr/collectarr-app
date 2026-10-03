import '../movie_module_dependencies.dart';
import '../entries/movie_transfer_library_entry.dart';

final movieKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.catalogItem,
      builder: buildMovieLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.libraryEntry,
      builder: buildMovieLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(MovieVocabularies.all),
  presentation: movieLibraryEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: MovieVocabularies.condition.builtIns,
  entryCollectionValueReader: (libraryEntry) => switch (libraryEntry?.value) {
    MovieLibraryEntry item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  createSession: createMovieEditDraft,
  entryDigitalFlagResolver: resolveMovieEntryDigitalFlag,
  entryFormatHintResolver: resolveMovieEntryFormatHint,
  entryIndexUpdatePayloadBuilder: (_, indexNumber) =>
      MovieLibraryEntryUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  entryConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      MovieLibraryEntryUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  entryBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          MovieLibraryEntryUpdatePayload.partial(
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
      MovieLibraryEntryUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  entryTransferUpdatePayloadBuilder: (_, updated) {
    final typed = movieTransferLibraryEntry(updated);
    return MovieLibraryEntryUpdatePayload.partial(
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
        const MovieEntryDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  entryDetailsResetPayloadBuilder: () =>
      MovieLibraryEntryUpdatePayload.partial(details: const Patch.clear()),
);
