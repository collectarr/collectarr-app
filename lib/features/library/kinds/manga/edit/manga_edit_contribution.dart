import '../manga_module_dependencies.dart';
import '../entries/manga_transfer_library_entry.dart';

final mangaKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.catalogItem,
      builder: buildMangaLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.libraryEntry,
      builder: buildMangaLibraryEditDialog,
    ),
  ]),
  presentation: mangaLibraryEditPresentation,
  coreCorrectionTargetResolver: resolveStructuralLibraryCoreCorrectionTarget,
  conditions: MangaVocabularies.condition.builtIns,
  entryCollectionValueReader: (libraryEntry) => switch (libraryEntry?.value) {
    MangaLibraryEntry item => item.grade,
    _ => null,
  },
  vocabularies: StandardKindVocabularyCapability(MangaVocabularies.all),
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  editChrome: const LibraryEditChromeConfig(
    titleUsesItemTitle: true,
    showsIssueBadge: true,
    showsPhysicalFormatBadge: true,
  ),
  createSession: createMangaEditDraft,
  entryDigitalFlagResolver: resolveMangaEntryDigitalFlag,
  entryFormatHintResolver: resolveMangaEntryFormatHint,
  entryIndexUpdatePayloadBuilder: (_, indexNumber) =>
      MangaLibraryEntryUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  entryConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      MangaLibraryEntryUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  entryBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          MangaLibraryEntryUpdatePayload.partial(
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
      MangaLibraryEntryUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  entryTransferUpdatePayloadBuilder: (_, updated) {
    final typed = mangaTransferLibraryEntry(updated);
    return MangaLibraryEntryUpdatePayload.partial(
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
        const MangaEntryDetailsCodec().draftFromDetails(
          typed.details,
        ),
      ),
    );
  },
  entryDetailsResetPayloadBuilder: () =>
      MangaLibraryEntryUpdatePayload.partial(details: const Patch.clear()),
);

Iterable<String> getMangaFacetValues(
    MangaWorkspaceDto dto, LibraryFacetIdRuntime facetId) {
  for (final definition in mangaLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}
