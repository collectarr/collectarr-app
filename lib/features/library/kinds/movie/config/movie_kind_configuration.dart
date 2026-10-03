import '../movie_module_dependencies.dart';

const movieCollectionFilterId = LibraryAddFilterId('movie.collection');
const movieYearFilterId = LibraryAddFilterId('movie.year');
const movieSearchScope = LibraryAddSearchScope(
  kind: CatalogMediaKind.movie,
  catalogValue: 'movie',
);
const movieCollectionSearchScope = LibraryAddSearchScope(
  kind: CatalogMediaKind.movie,
  catalogValue: 'collection',
);

final movieAddChrome = LibraryAddChromeConfig(
  kindFilterOptions: [
    LibraryAddKindFilterOption(
      scope: movieSearchScope,
      label: 'Movies',
      icon: Icons.movie_outlined,
    ),
    LibraryAddKindFilterOption(
      scope: movieCollectionSearchScope,
      label: 'Box Sets',
      icon: Icons.collections_bookmark_outlined,
    ),
  ],
  defaultKindFilters: {movieSearchScope},
);

TransferableField movieTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(MovieLibraryEntry item) read,
  required MovieLibraryEntry Function(MovieLibraryEntry item, String? value)
      write,
  LibraryEntityScope scope = LibraryEntityScope.libraryEntry,
}) {
  return TransferableField.typed<MovieLibraryEntry>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as MovieLibraryEntry,
    read: read,
    write: write,
  );
}

final movieUniversalTransferableFields =
    TransferableField.universalForTyped<MovieLibraryEntry>(
  decode: (value) => value as MovieLibraryEntry,
  readCondition: (item) => item.condition,
  writeCondition: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(condition: value)),
  readPersonalNotes: (item) => item.personalNotes,
  writePersonalNotes: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(personalNotes: value)),
  readLocationId: (item) => item.locationId,
  writeLocationId: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(locationId: value)),
  readTags: (item) => item.tags,
  writeTags: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(tags: value)),
  readCurrency: (item) => item.currency,
  writeCurrency: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(currency: value)),
  readSoldTo: (item) => item.soldTo,
  writeSoldTo: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(soldTo: value)),
  readPurchaseStore: (item) => item.purchaseStore,
  writePurchaseStore: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(purchaseStore: value)),
  readPricePaidCents: (item) => item.pricePaidCents?.toString(),
  writePricePaidCents: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    pricePaidCents: value == null ? null : int.tryParse(value),
  )),
  readSellPriceCents: (item) => item.sellPriceCents?.toString(),
  writeSellPriceCents: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    sellPriceCents: value == null ? null : int.tryParse(value),
  )),
  readIndexNumber: (item) => item.indexNumber?.toString(),
  writeIndexNumber: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    indexNumber: value == null ? null : int.tryParse(value),
  )),
  readPurchaseDate: (item) => item.purchaseDate?.toIso8601String(),
  writePurchaseDate: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    purchaseDate: value == null ? null : DateTime.tryParse(value),
  )),
  readSoldAt: (item) => item.soldAt?.toIso8601String(),
  writeSoldAt: (item, value) => item.copyWith(
      personal: item.personal.copyWith(
    soldAt: value == null ? null : DateTime.tryParse(value),
  )),
);

final movieTransferableFields = <TransferableField>[
  movieTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
  movieTransferField(
    key: 'features',
    label: 'Features',
    icon: Icons.featured_play_list_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.details.features,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
              details: item.personal.details.copyWith(features: value)));
    },
  ),
  movieTransferField(
    key: 'boxSetName',
    label: 'Box set name',
    icon: Icons.inventory_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.details.boxSetName,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
              details: item.personal.details.copyWith(boxSetName: value)));
    },
  ),
  movieTransferField(
    key: 'packaging',
    label: 'Packaging',
    icon: Icons.inventory_2_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.details.packaging,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
              details: item.personal.details.copyWith(packaging: value)));
    },
  ),
];

Iterable<String?> movieLinkedMetadataValues(MovieCatalogMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      metadata.studio,
      metadata.variant,
      metadata.country,
      metadata.originalLanguage,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

MovieCatalogMetadata? movieLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is MovieWorkspaceCatalogData ? catalog.metadata : null;
}

MetadataSearchQuery movieMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = movieLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode,
    issueNumber: metadata?.itemNumber,
    publisher: metadata?.publisher,
    year: metadata?.releaseDate?.year,
    limit: 5,
  );
}

const movieLibraryFacetModule = LibraryFacetModule();
