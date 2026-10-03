import '../music_module_dependencies.dart';
import '../entries/music_transfer_library_entry.dart';

final musicKindEditCapabilities = LibraryEditCapabilitySet(
  editRegistry: LibraryEntityEditRegistry(contributors: [
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.catalogItem,
      builder: buildMusicAlbumLibraryEditDialog,
    ),
    LibraryEntityEditContributor(
      scope: LibraryEntityScope.libraryEntry,
      builder: buildMusicAlbumLibraryEditDialog,
    ),
  ]),
  vocabularies: StandardKindVocabularyCapability(MusicVocabularies.all),
  presentation: musicTypedEditPresentation,
  coreCorrectionTargetResolver: resolveMusicCatalogItemCoreCorrectionTarget,
  conditions: MusicVocabularies.condition.builtIns,
  entryCollectionValueReader: (libraryEntry) => switch (libraryEntry?.value) {
    MusicLibraryEntry item => item.personal.grade,
    _ => null,
  },
  defaultCondition: 'Near Mint',
  defaultCollectionValue: 'Ungraded',
  entryDigitalFlagResolver: resolveMusicEntryDigitalFlag,
  entryFormatHintResolver: resolveMusicEntryFormatHint,
  entryIndexUpdatePayloadBuilder: (_, indexNumber) =>
      MusicLibraryEntryUpdatePayload.partial(
    indexNumber: Patch.set(indexNumber),
  ),
  entryConditionValueUpdatePayloadBuilder: (_, condition, collectionValue) =>
      MusicLibraryEntryUpdatePayload.partial(
    condition: Patch.set(condition),
    grade: Patch.set(collectionValue),
  ),
  entryBulkUpdatePayloadBuilder:
      (_, condition, collectionValue, locationId, tags) =>
          MusicLibraryEntryUpdatePayload.partial(
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
      MusicLibraryEntryUpdatePayload.partial(
    purchaseDate: Patch.set(purchaseDate),
    pricePaidCents: Patch.set(pricePaidCents),
    currency: Patch.set(currency),
    personalNotes: Patch.set(personalNotes),
    purchaseStore: Patch.set(purchaseStore),
    locationId:
        locationChanged ? Patch.set(locationId) : const Patch.unchanged(),
  ),
  entryTransferUpdatePayloadBuilder: (_, updated) {
    final typed = musicTransferLibraryEntry(updated);
    return MusicLibraryEntryUpdatePayload.partial(
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
        const MusicEntryDetailsCodec().draftFromDetails(
          typed.personal.details,
        ),
      ),
    );
  },
  entryDetailsResetPayloadBuilder: () =>
      MusicLibraryEntryUpdatePayload.partial(details: const Patch.clear()),
);

LibraryCoreCorrectionTarget resolveMusicCatalogItemCoreCorrectionTarget({
  required LibraryEntityRef? node,
  required LibraryEntityScope? requestedScope,
  required CatalogEntityRef catalogRef,
}) {
  final id = catalogRef.id.trim();
  if (catalogRef.mediaKind != CatalogMediaKind.music || id.isEmpty) {
    throw StateError('Music correction requires a concrete Catalog Item.');
  }
  return LibraryCoreCorrectionTarget(scope: 'catalog_item', entityId: id);
}
