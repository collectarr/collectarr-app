import '../anime_module_dependencies.dart';

const animeSeriesFilterId = LibraryAddFilterId('anime.series');
const animeStudioFilterId = LibraryAddFilterId('anime.studio');
const animeSearchScope = LibraryAddSearchScope(
  kind: CatalogMediaKind.anime,
  providerValue: 'anime',
);
const animeYearFilterId = LibraryAddFilterId('anime.year');

final animeAddChrome = LibraryAddChromeConfig(
  kindFilterOptions: [
    LibraryAddKindFilterOption(
      scope: animeSearchScope,
      label: 'Anime',
      icon: Icons.auto_awesome_outlined,
    ),
  ],
  defaultKindFilters: {animeSearchScope},
);

TransferableField animeTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(AnimeOwnedItem item) read,
  required AnimeOwnedItem Function(AnimeOwnedItem item, String? value) write,
  LibraryEntityScope scope = LibraryEntityScope.copy,
}) {
  return TransferableField.typed<AnimeOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as AnimeOwnedItem,
    read: read,
    write: write,
  );
}

final animeUniversalTransferableFields =
    TransferableField.universalForTyped<AnimeOwnedItem>(
  decode: (value) => value as AnimeOwnedItem,
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

final animeTransferableFields = <TransferableField>[
  animeTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
  animeTransferField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.copy,
    read: (item) => item.details.features,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(features: value));
    },
  ),
  animeTransferField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.copy,
    read: (item) => item.details.boxSetName,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(boxSetName: value));
    },
  ),
  animeTransferField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.copy,
    read: (item) => item.details.packaging,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(packaging: value));
    },
  ),
];

Iterable<String?> animeLinkedMetadataValues(AnimeMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      ...metadata.studios,
      ...metadata.producers,
      metadata.variant,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

AnimeMetadata? animeLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is AnimeWorkspaceCatalogData ? catalog.metadata : null;
}

MetadataSearchQuery animeMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = animeLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode,
    issueNumber: metadata?.itemNumber,
    publisher: metadata?.publisher,
    year: metadata?.seasonYear,
    limit: 5,
  );
}

const animeLibraryFacetModule = LibraryFacetModule();
