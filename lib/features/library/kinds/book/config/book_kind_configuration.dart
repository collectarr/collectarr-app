import '../book_module_dependencies.dart';
import '../add/book_add_contribution.dart';

const bookAuthorFilterId = LibraryAddFilterId('book.author');
const bookIsbnFilterId = LibraryAddFilterId('book.isbn');
const bookPublisherFilterId = LibraryAddFilterId('book.publisher');
const bookYearFilterId = LibraryAddFilterId('book.year');

TransferableField bookTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(BookLibraryEntry item) read,
  required BookLibraryEntry Function(BookLibraryEntry item, String? value)
      write,
  LibraryEntityScope scope = LibraryEntityScope.libraryEntry,
}) {
  return TransferableField.typed<BookLibraryEntry>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as BookLibraryEntry,
    read: read,
    write: write,
  );
}

final bookUniversalTransferableFields =
    TransferableField.universalForTyped<BookLibraryEntry>(
  decode: (value) => value as BookLibraryEntry,
  readCondition: (item) => item.personal.condition,
  writeCondition: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(condition: value)),
  readPersonalNotes: (item) => item.personal.personalNotes,
  writePersonalNotes: (item, value) => item.copyWith(
    personal: item.personal.copyWith(personalNotes: value),
  ),
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
    ),
  ),
  readSellPriceCents: (item) => item.personal.sellPriceCents?.toString(),
  writeSellPriceCents: (item, value) => item.copyWith(
    personal: item.personal.copyWith(
      sellPriceCents: value == null ? null : int.tryParse(value),
    ),
  ),
  readIndexNumber: (item) => item.personal.indexNumber?.toString(),
  writeIndexNumber: (item, value) => item.copyWith(
    personal: item.personal.copyWith(
      indexNumber: value == null ? null : int.tryParse(value),
    ),
  ),
  readPurchaseDate: (item) => item.personal.purchaseDate?.toIso8601String(),
  writePurchaseDate: (item, value) => item.copyWith(
    personal: item.personal.copyWith(
      purchaseDate: value == null ? null : DateTime.tryParse(value),
    ),
  ),
  readSoldAt: (item) => item.personal.soldAt?.toIso8601String(),
  writeSoldAt: (item, value) => item.copyWith(
    personal: item.personal.copyWith(
      soldAt: value == null ? null : DateTime.tryParse(value),
    ),
  ),
);

final bookTransferableFields = <TransferableField>[
  bookTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
  bookTransferField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.details.signedBy,
    write: (item, value) {
      return item.copyWith(
        personal: item.personal.copyWith(
          details: item.personal.details.copyWith(signedBy: value),
        ),
      );
    },
  ),
  bookTransferField(
    key: 'dustJacketPresent',
    label: 'Dust jacket',
    icon: Icons.book_outlined,
    type: TransferableFieldType.boolean,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.personal.details.dustJacketPresent ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
        personal: item.personal.copyWith(
          details: item.personal.details.copyWith(
            dustJacketPresent: value == 'true',
          ),
        ),
      );
    },
  ),
  bookTransferField(
    key: 'dustJacketCondition',
    label: 'Dust jacket condition',
    icon: Icons.grade_outlined,
    type: TransferableFieldType.text,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.personal.details.dustJacketCondition,
    write: (item, value) {
      return item.copyWith(
        personal: item.personal.copyWith(
          details: item.personal.details.copyWith(
            dustJacketCondition: value,
          ),
        ),
      );
    },
  ),
];

Iterable<String?> bookLinkedMetadataValues(BookCatalogMetadata metadata) => [
      metadata.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      metadata.variant,
      metadata.imprint,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit.name),
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
    year: metadata?.releaseDate?.year,
    limit: 5,
  );
}

final bookLibraryFacetModule = TypedLibraryFacetModule<BookWorkspaceDto>(
  getFacetValues: getBookFacetValues,
  externalFacetBucketIdsByMode: {
    'book.genre': BookFacetIds.genre,
    'book.subject': BookFacetIds.subject,
  },
);
