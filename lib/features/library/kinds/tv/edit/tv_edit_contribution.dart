import '../tv_module_dependencies.dart';
import '../entries/tv_transfer_library_entry.dart';

final tvKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.catalogItem,
      builder: buildTvLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.libraryEntry,
      builder: buildTvMediaLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(TvVocabularies.all),
  presentation: tvLibraryEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: TvVocabularies.condition.builtIns,
  entryCollectionValueReader: (libraryEntry) => switch (libraryEntry?.value) {
    TvLibraryEntry item => item.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  createSession: createTvEditDraft,
  entryDigitalFlagResolver: resolveTvEntryDigitalFlag,
  entryFormatHintResolver: resolveTvEntryFormatHint,
  entryIndexUpdatePayloadBuilder: (_, indexNumber) =>
      TvLibraryEntryUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  entryConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      TvLibraryEntryUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  entryBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          TvLibraryEntryUpdatePayload.partial(
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
      TvLibraryEntryUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  entryTransferUpdatePayloadBuilder: (_, updated) {
    final typed = tvTransferLibraryEntry(updated);
    return TvLibraryEntryUpdatePayload.partial(
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
        const TvEntryDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  entryDetailsResetPayloadBuilder: () =>
      TvLibraryEntryUpdatePayload.partial(details: const Patch.clear()),
);
