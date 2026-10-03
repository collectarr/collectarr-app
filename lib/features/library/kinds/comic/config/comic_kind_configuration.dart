import '../comic_module_dependencies.dart';
import '../add/comic_add_contribution.dart';

const comicSeriesFilterId = LibraryAddFilterId('comic.series');
const comicIssueFilterId = LibraryAddFilterId('comic.issue');
const comicPublisherFilterId = LibraryAddFilterId('comic.publisher');
const comicYearFilterId = LibraryAddFilterId('comic.year');

const comicTransferableFieldKeys = <String>[
  ...kDefaultTransferableFieldKeys,
  'grade',
  'rawOrSlabbed',
  'gradingCompany',
  'graderNotes',
  'signedBy',
  'keyReason',
  'keyComic',
  'coverPriceCents',
];

final comicUniversalTransferableFields =
    TransferableField.universalForTyped<ComicLibraryEntry>(
  decode: (value) => value as ComicLibraryEntry,
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

Iterable<String?> comicLinkedMetadataValues(ComicCatalogItem metadata) => [
      metadata.seriesTitle,
      metadata.issueNumber,
      metadata.publisher,
      metadata.variant,
      metadata.imprint,
      metadata.country,
      metadata.language,
      ...metadata.contributors.map((credit) => credit.name),
      ...metadata.creators.map((credit) => credit.name),
      ...metadata.genres,
    ];

ComicCatalogItem? comicLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is ComicWorkspaceCatalogData ? catalog.comic : null;
}

MetadataSearchQuery comicMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = comicLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode,
    issueNumber: metadata?.issueNumber,
    publisher: metadata?.publisher,
    year: metadata?.releaseDate?.year,
    limit: 5,
  );
}

final comicLibraryFacetModule = TypedLibraryFacetModule<ComicWorkspaceDto>(
  loadRows: loadComicFacetRows,
  getFacetValues: getComicFacetValues,
  externalFacetBucketIdsByMode: {
    'comic.story_arc': ComicFacetIds.storyArc,
    'comic.character': ComicFacetIds.character,
  },
);
