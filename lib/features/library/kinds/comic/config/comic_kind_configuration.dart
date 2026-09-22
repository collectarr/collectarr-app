import '../comic_module_dependencies.dart';
import '../add/comic_add_contribution.dart';

const comicSeriesFilterId = LibraryAddFilterId('comic.series');
const comicIssueFilterId = LibraryAddFilterId('comic.issue');
const comicPublisherFilterId = LibraryAddFilterId('comic.publisher');
const comicYearFilterId = LibraryAddFilterId('comic.year');

String? comicHierarchyContractDiagnosticLabel(LibraryProjectionView item) {
  final dto = item.dto;
  if (dto is! ComicWorkspaceDto) {
    return null;
  }
  if (dto.seriesTitle?.trim().isNotEmpty != true) {
    return 'Missing series title';
  }
  if (item.node.scope != LibraryEntityScope.work &&
      dto.variant?.trim().isNotEmpty != true) {
    return 'Missing release variant';
  }
  return null;
}

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
    TransferableField.universalForTyped<ComicOwnedItem>(
  decode: (value) => value as ComicOwnedItem,
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

Iterable<String?> comicLinkedMetadataValues(ComicMedia metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.issueNumber,
      metadata.publisher,
      metadata.publishing?.originalPublisher,
      metadata.variant,
      metadata.imprint,
      metadata.publishing?.imprint,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

ComicMedia? comicLinkedMetadata(LibraryWorkspaceSource source) {
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

ComicOwnedItem comicTransferOwnedItem(Object value) {
  if (value is ComicOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected ComicOwnedItem');
}
