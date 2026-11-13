import '../book_module_dependencies.dart';
import '../add/contribution.dart';

const bookAuthorFilterId = LibraryAddFilterId('book.author');
const bookIsbnFilterId = LibraryAddFilterId('book.isbn');
const bookPublisherFilterId = LibraryAddFilterId('book.publisher');
const bookYearFilterId = LibraryAddFilterId('book.year');

final bookUniversalTransferableFields =
    TransferableField.universalForTyped<BookLibraryEntry>(
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
  TransferableField.typed<BookLibraryEntry>(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
  TransferableField.typed<BookLibraryEntry>(
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
  TransferableField.typed<BookLibraryEntry>(
    key: 'dustJacketPresent',
    label: 'Dust jacket',
    icon: Icons.book_outlined,
    type: TransferableFieldType.boolean,
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
  TransferableField.typed<BookLibraryEntry>(
    key: 'dustJacketCondition',
    label: 'Dust jacket condition',
    icon: Icons.grade_outlined,
    type: TransferableFieldType.text,
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

Iterable<(String, String?)> bookLinkedMetadataValues(
        BookCatalogMetadata metadata) =>
    [
      ('Series', metadata.seriesTitle),
      ('Series Group', metadata.seriesGroup),
      ('Number', metadata.itemNumber),
      ('Publisher', metadata.publisher),
      ('Edition', metadata.variant),
      ('Imprint', metadata.imprint),
      ('Country', metadata.country),
      ('Language', metadata.language),
      ...metadata.creators.map((credit) => ('Creator', credit.name)),
      ...metadata.genres.map((genre) => ('Genre', genre)),
    ];

BookCatalogMetadata? bookLinkedMetadata(LibraryWorkspaceContext source) {
  final catalog = source.kindPresentationData;
  return catalog is BookWorkspaceData ? catalog.metadata : null;
}

MetadataSearchQuery bookMetadataSearchQuery({
  required LibraryWorkspaceContext source,
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
