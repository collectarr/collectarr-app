import '../manga_module_dependencies.dart';
import '../edit/manga_edit_contribution.dart';

const mangaSeriesFilterId = LibraryAddFilterId('manga.series');
const mangaVolumeFilterId = LibraryAddFilterId('manga.volume');
const mangaPublisherFilterId = LibraryAddFilterId('manga.publisher');
const mangaYearFilterId = LibraryAddFilterId('manga.year');

TransferableField mangaTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(MangaOwnedItem item) read,
  required MangaOwnedItem Function(MangaOwnedItem item, String? value) write,
  LibraryEntityScope scope = LibraryEntityScope.copy,
}) {
  return TransferableField.typed<MangaOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as MangaOwnedItem,
    read: read,
    write: write,
  );
}

final mangaUniversalTransferableFields =
    TransferableField.universalForTyped<MangaOwnedItem>(
  decode: (value) => value as MangaOwnedItem,
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

final mangaTransferableFields = <TransferableField>[
  mangaTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
  mangaTransferField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.signedBy,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(signedBy: value));
    },
  ),
  mangaTransferField(
    key: 'gradingCompany',
    label: 'Grading company',
    icon: Icons.verified_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.gradingCompany,
    write: (item, value) {
      return item.copyWith(
        details: item.details.copyWith(gradingCompany: value),
      );
    },
  ),
  mangaTransferField(
    key: 'graderNotes',
    label: 'Grader notes',
    icon: Icons.note_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.details.graderNotes,
    write: (item, value) {
      return item.copyWith(details: item.details.copyWith(graderNotes: value));
    },
  ),
  mangaTransferField(
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
  mangaTransferField(
    key: 'obiStripPresent',
    label: 'Obi strip',
    icon: Icons.bookmark_border,
    type: TransferableFieldType.boolean,
    scope: LibraryEntityScope.copy,
    read: (item) => item.details.obiStripPresent ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
        details: item.details.copyWith(obiStripPresent: value == 'true'),
      );
    },
  ),
];

Iterable<String?> mangaLinkedMetadataValues(MangaMetadata metadata) => [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      metadata.originalPublisher,
      metadata.localizedPublisher,
      metadata.variant,
      metadata.imprint,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

MangaMetadata? mangaLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is MangaWorkspaceCatalogData ? catalog.metadata : null;
}

MetadataSearchQuery mangaMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = mangaLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode ?? metadata?.isbn,
    issueNumber: metadata?.itemNumber,
    publisher: metadata?.publisher,
    year: (metadata?.localizedReleaseDate ?? metadata?.originalPublicationDate)
        ?.year,
    limit: 5,
  );
}

final mangaLibraryFacetModule = TypedLibraryFacetModule<MangaWorkspaceDto>(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  getFacetValues: getMangaFacetValues,
  externalFacetBucketIdsByMode: {
    'manga.genre': MangaFacetIds.genre,
    'manga.demographic': MangaFacetIds.demographic,
  },
);
