import '../anime_module_dependencies.dart';

const animeSeriesFilterId = LibraryAddFilterId('anime.series');
const animeStudioFilterId = LibraryAddFilterId('anime.studio');
const animeSearchScope = LibraryAddSearchScope(
  kind: CatalogMediaKind.anime,
  catalogValue: 'anime',
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
  required String? Function(AnimeLibraryEntry item) read,
  required AnimeLibraryEntry Function(AnimeLibraryEntry item, String? value)
      write,
  LibraryEntityScope scope = LibraryEntityScope.libraryEntry,
}) {
  return TransferableField.typed<AnimeLibraryEntry>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as AnimeLibraryEntry,
    read: read,
    write: write,
  );
}

final animeUniversalTransferableFields =
    TransferableField.universalForTyped<AnimeLibraryEntry>(
  decode: (value) => value as AnimeLibraryEntry,
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

final animeTransferableFields = <TransferableField>[
  animeTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
  animeTransferField(
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
  animeTransferField(
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
  animeTransferField(
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

Iterable<String?> animeLinkedMetadataValues(AnimeMetadata metadata) => [
      metadata.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      ...metadata.studios,
      ...metadata.producers,
      metadata.variant,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit.name),
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
