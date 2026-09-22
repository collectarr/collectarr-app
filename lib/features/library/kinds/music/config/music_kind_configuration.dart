import '../music_module_dependencies.dart';

const musicArtistFilterId = musicAddArtistFilterId;
const musicLabelFilterId = musicAddLabelFilterId;
const musicYearFilterId = musicAddYearFilterId;

TransferableField musicTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(MusicOwnedItem item) read,
  required MusicOwnedItem Function(MusicOwnedItem item, String? value) write,
  LibraryEntityScope scope = LibraryEntityScope.copy,
}) {
  return TransferableField.typed<MusicOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as MusicOwnedItem,
    read: read,
    write: write,
  );
}

final musicUniversalTransferableFields =
    TransferableField.universalForTyped<MusicOwnedItem>(
  decode: (value) => value as MusicOwnedItem,
  readCondition: (item) => item.condition,
  writeCondition: (item, value) => item.copyWith(condition: value),
  readPersonalNotes: (item) => item.personalNotes,
  writePersonalNotes: (item, value) => item.copyWith(personalNotes: value),
  readLocationId: (item) => item.locationId,
  writeLocationId: (item, value) => item.copyWith(locationId: value),
  readTags: (item) => item.tags,
  writeTags: (item, value) => item.copyWith(tags: value),
  readCurrency: (item) => item.currency,
  writeCurrency: (item, value) => item.copyWith(currency: value),
  readSoldTo: (item) => item.soldTo,
  writeSoldTo: (item, value) => item.copyWith(soldTo: value),
  readPurchaseStore: (item) => item.purchaseStore,
  writePurchaseStore: (item, value) => item.copyWith(purchaseStore: value),
  readPricePaidCents: (item) => item.pricePaidCents?.toString(),
  writePricePaidCents: (item, value) => item.copyWith(
    pricePaidCents: value == null ? null : int.tryParse(value),
  ),
  readSellPriceCents: (item) => item.sellPriceCents?.toString(),
  writeSellPriceCents: (item, value) => item.copyWith(
    sellPriceCents: value == null ? null : int.tryParse(value),
  ),
  readQuantity: (item) => item.quantity.toString(),
  writeQuantity: (item, value) => item.copyWith(
    quantity: value == null ? 1 : int.tryParse(value) ?? 1,
  ),
  readIndexNumber: (item) => item.indexNumber?.toString(),
  writeIndexNumber: (item, value) => item.copyWith(
    indexNumber: value == null ? null : int.tryParse(value),
  ),
  readPurchaseDate: (item) => item.purchaseDate?.toIso8601String(),
  writePurchaseDate: (item, value) => item.copyWith(
    purchaseDate: value == null ? null : DateTime.tryParse(value),
  ),
  readSoldAt: (item) => item.soldAt?.toIso8601String(),
  writeSoldAt: (item, value) => item.copyWith(
    soldAt: value == null ? null : DateTime.tryParse(value),
  ),
);

final musicTransferableFields = <TransferableField>[
  musicTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
];

const musicAddChrome = LibraryAddChromeConfig(
  mediaReferenceLabel: 'Album',
  trackScopeSummary:
      'Tracking stays album-level here. Edition and variant scope are only available for owned or wishlist entries.',
  mediaReferenceHelperLabel: 'Track or save the album itself.',
  editionReferenceHelperLabel:
      'Attach ownership to an album edition. Pick a variant only if you want one exact format or pressing.',
);

Iterable<String?> musicLinkedMetadataValues(MusicReleaseGroup group) => [
      group.artist,
      group.primaryRelease?.publisher,
      group.primaryRelease?.countryCode,
      group.primaryRelease?.language,
      ...?group.primaryRelease?.contributions
          .map((credit) => credit.displayName),
      ...group.genres,
    ];

MusicReleaseGroup? musicLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is MusicWorkspaceCatalogData ? catalog.music : null;
}

MetadataSearchQuery musicMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = musicLinkedMetadata(source);
  final release = metadata?.primaryRelease;
  return MetadataSearchQuery(
    query: title,
    barcode: release?.barcode ?? release?.upc,
    publisher: release?.publisher,
    year: metadata?.originalReleaseDate?.year,
    limit: 5,
  );
}

const musicLibraryFacetModule = LibraryFacetModule(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
);
