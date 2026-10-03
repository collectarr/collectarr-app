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
  required String? Function(MangaLibraryEntry item) read,
  required MangaLibraryEntry Function(MangaLibraryEntry item, String? value)
      write,
  LibraryEntityScope scope = LibraryEntityScope.libraryEntry,
}) {
  return TransferableField.typed<MangaLibraryEntry>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as MangaLibraryEntry,
    read: read,
    write: write,
  );
}

final mangaUniversalTransferableFields =
    TransferableField.universalForTyped<MangaLibraryEntry>(
  decode: (value) => value as MangaLibraryEntry,
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

final mangaTransferableFields = <TransferableField>[
  mangaTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
  mangaTransferField(
    key: 'signedBy',
    label: 'Signed by',
    icon: Icons.draw_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.details.signedBy,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
              details: item.personal.details.copyWith(signedBy: value)));
    },
  ),
  mangaTransferField(
    key: 'gradingCompany',
    label: 'Grading company',
    icon: Icons.verified_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.details.gradingCompany,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
        details: item.personal.details.copyWith(gradingCompany: value),
      ));
    },
  ),
  mangaTransferField(
    key: 'graderNotes',
    label: 'Grader notes',
    icon: Icons.note_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.details.graderNotes,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
              details: item.personal.details.copyWith(graderNotes: value)));
    },
  ),
  mangaTransferField(
    key: 'dustJacketPresent',
    label: 'Dust jacket',
    icon: Icons.book_outlined,
    type: TransferableFieldType.boolean,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.personal.details.dustJacketPresent ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
        details:
            item.personal.details.copyWith(dustJacketPresent: value == 'true'),
      ));
    },
  ),
  mangaTransferField(
    key: 'obiStripPresent',
    label: 'Obi strip',
    icon: Icons.bookmark_border,
    type: TransferableFieldType.boolean,
    scope: LibraryEntityScope.libraryEntry,
    read: (item) => item.personal.details.obiStripPresent ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
        details:
            item.personal.details.copyWith(obiStripPresent: value == 'true'),
      ));
    },
  ),
];

Iterable<String?> mangaLinkedMetadataValues(MangaMetadata metadata) => [
      metadata.seriesTitle,
      metadata.volumeNumber?.toString(),
      metadata.publisher,
      metadata.originalPublisher,
      metadata.localizedPublisher,
      metadata.variant,
      metadata.imprint,
      metadata.country,
      metadata.language,
      ...metadata.creators.map((credit) => credit.name),
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
    issueNumber: metadata?.volumeNumber?.toString(),
    publisher: metadata?.publisher,
    year: (metadata?.localizedReleaseDate ?? metadata?.originalPublicationDate)
        ?.year,
    limit: 5,
  );
}

final mangaLibraryFacetModule = TypedLibraryFacetModule<MangaWorkspaceDto>(
  getFacetValues: getMangaFacetValues,
  externalFacetBucketIdsByMode: {
    'manga.genre': MangaFacetIds.genre,
    'manga.demographic': MangaFacetIds.demographic,
  },
);
