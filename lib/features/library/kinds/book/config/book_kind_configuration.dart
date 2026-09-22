import '../book_module_dependencies.dart';

const bookAuthorFilterId = LibraryAddFilterId('book.author');
const bookIsbnFilterId = LibraryAddFilterId('book.isbn');
const bookPublisherFilterId = LibraryAddFilterId('book.publisher');
const bookYearFilterId = LibraryAddFilterId('book.year');

TransferableField bookTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(BookOwnedItem item) read,
  required BookOwnedItem Function(BookOwnedItem item, String? value) write,
  LibraryEntityScope scope = LibraryEntityScope.copy,
}) {
  return TransferableField.typed<BookOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as BookOwnedItem,
    read: read,
    write: write,
  );
}

final bookUniversalTransferableFields =
    TransferableField.universalForTyped<BookOwnedItem>(
  decode: (value) => value as BookOwnedItem,
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

final bookTransferableFields = <TransferableField>[
  bookTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
  bookTransferField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.signedBy,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(signedBy: value));
    },
  ),
  bookTransferField(
    key: 'dustJacketPresent',
    label: 'Dust jacket',
    icon: Icons.book_outlined,
    type: TransferableFieldType.boolean,
    scope: LibraryEntityScope.copy,
    read: (item) => item.details.dustJacketPresent ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
        details: item.details.copyWith(dustJacketPresent: value == 'true'),
      );
    },
  ),
  bookTransferField(
    key: 'dustJacketCondition',
    label: 'Dust jacket condition',
    icon: Icons.grade_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.copy,
    read: (item) => item.details.dustJacketCondition,
    write: (item, value) {
      return item.copyWith(
        details: item.details.copyWith(dustJacketCondition: value),
      );
    },
  ),
];

Iterable<String?> bookLinkedMetadataValues(BookCatalogMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      metadata.originalPublisher,
      metadata.publishing?.originalPublisher,
      metadata.variant,
      metadata.publishing?.imprint,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

BookCatalogMetadata? bookLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is BookWorkspaceCatalogData ? catalog.metadata : null;
}

MetadataSearchQuery bookMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = bookLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode,
    issueNumber: metadata?.itemNumber,
    publisher: metadata?.publisher,
    year: metadata?.originalPublicationDate?.year,
    limit: 5,
  );
}

final bookLibraryFacetModule = TypedLibraryFacetModule<BookWorkspaceDto>(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  getFacetValues: _getBookFacetValues,
  externalFacetBucketIdsByMode: {
    'book.genre': BookFacetIds.genre,
    'book.subject': BookFacetIds.subject,
  },
);

BookOwnedItem bookTransferOwnedItem(Object value) {
  if (value is BookOwnedItem) return value;
  throw ArgumentError.value(value, 'updated', 'Expected BookOwnedItem');
}

