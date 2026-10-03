import '../tv_module_dependencies.dart';

const tvShowFilterId = LibraryAddFilterId('tv.show');
const tvNetworkFilterId = LibraryAddFilterId('tv.network');
const tvYearFilterId = LibraryAddFilterId('tv.year');
const tvSearchScope = LibraryAddSearchScope(
  kind: CatalogMediaKind.tv,
  catalogValue: 'tv',
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
  required String? Function(TvLibraryEntry item) read,
  required TvLibraryEntry Function(TvLibraryEntry item, String? value) write,
  LibraryEntityScope scope = LibraryEntityScope.libraryEntry,
}) {
  return TransferableField.typed<TvLibraryEntry>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as TvLibraryEntry,
    read: read,
    write: write,
  );
}

final tvUniversalTransferableFields =
    TransferableField.universalForTyped<TvLibraryEntry>(
  decode: (value) => value as TvLibraryEntry,
  readCondition: (item) => item.personal.condition,
  writeCondition: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(condition: value)),
  readPersonalNotes: (item) => item.personal.personalNotes,
  writePersonalNotes: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(personalNotes: value)),
  readLocationId: (item) => item.personal.locationId,
  writeLocationId: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(locationId: value)),
  readTags: (item) => item.personal.tags,
  writeTags: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(tags: value)),
  readCurrency: (item) => item.personal.currency,
  writeCurrency: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(currency: value)),
  readSoldTo: (item) => item.personal.soldTo,
  writeSoldTo: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(soldTo: value)),
  readPurchaseStore: (item) => item.personal.purchaseStore,
  writePurchaseStore: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(purchaseStore: value)),
  readPricePaidCents: (item) => item.personal.pricePaidCents?.toString(),
  writePricePaidCents: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    pricePaidCents: value == null ? null : int.tryParse(value),
  )),
  readSellPriceCents: (item) => item.personal.sellPriceCents?.toString(),
  writeSellPriceCents: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    sellPriceCents: value == null ? null : int.tryParse(value),
  )),
  readIndexNumber: (item) => item.personal.indexNumber?.toString(),
  writeIndexNumber: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    indexNumber: value == null ? null : int.tryParse(value),
  )),
  readPurchaseDate: (item) => item.personal.purchaseDate?.toIso8601String(),
  writePurchaseDate: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    purchaseDate: value == null ? null : DateTime.tryParse(value),
  )),
  readSoldAt: (item) => item.personal.soldAt?.toIso8601String(),
  writeSoldAt: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    soldAt: value == null ? null : DateTime.tryParse(value),
  )),
);

final tvTransferableFields = <TransferableField>[
  tvTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
  tvTransferField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.personal.details.features,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
              details: item.personal.details.copyWith(features: value)));
    },
  ),
  tvTransferField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.personal.details.boxSetName,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
              details: item.personal.details.copyWith(boxSetName: value)));
    },
  ),
  tvTransferField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.personal.details.packaging,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
              details: item.personal.details.copyWith(packaging: value)));
    },
  ),
];

Iterable<String?> tvLinkedMetadataValues(TvSeriesMetadata metadata) => [
      metadata.seriesTitle,
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
