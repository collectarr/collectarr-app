import '../tv_module_dependencies.dart';

const tvShowFilterId = LibraryAddFilterId('tv.show');
const tvNetworkFilterId = LibraryAddFilterId('tv.network');
const tvYearFilterId = LibraryAddFilterId('tv.year');
const tvSearchScope = LibraryAddSearchScope(
  kind: CatalogMediaKind.tv,
  providerValue: 'tv',
);

final tvAddChrome = LibraryAddChromeConfig(
  kindFilterOptions: [
    LibraryAddKindFilterOption(
      scope: tvSearchScope,
      label: 'TV Shows',
      icon: Icons.tv_outlined,
    ),
  ],
  defaultKindFilters: {tvSearchScope},
);

TransferableField tvTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(TvOwnedItem item) read,
  required TvOwnedItem Function(TvOwnedItem item, String? value) write,
  LibraryEntityScope scope = LibraryEntityScope.copy,
}) {
  return TransferableField.typed<TvOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as TvOwnedItem,
    read: read,
    write: write,
  );
}

final tvUniversalTransferableFields =
    TransferableField.universalForTyped<TvOwnedItem>(
  decode: (value) => value as TvOwnedItem,
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

final tvTransferableFields = <TransferableField>[
  tvTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
  tvTransferField(
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
  tvTransferField(
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
  tvTransferField(
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

Iterable<String?> tvLinkedMetadataValues(TvSeriesMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      metadata.network,
      metadata.streamingService,
      metadata.variant,
      metadata.country,
      metadata.originalLanguage,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

TvSeriesMetadata? tvLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is TvWorkspaceCatalogData ? catalog.metadata : null;
}

MetadataSearchQuery tvMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = tvLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode,
    issueNumber: metadata?.itemNumber,
    publisher: metadata?.publisher,
    year: metadata?.firstAirDate?.year,
    limit: 5,
  );
}

const tvLibraryFacetModule = LibraryFacetModule();
