import '../music_module_dependencies.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';

const musicArtistFilterId = musicAddArtistFilterId;
const musicLabelFilterId = musicAddLabelFilterId;
const musicYearFilterId = musicAddYearFilterId;

TransferableField musicTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(MusicLibraryEntry item) read,
  required MusicLibraryEntry Function(MusicLibraryEntry item, String? value)
      write,
  LibraryEntityScope scope = LibraryEntityScope.libraryEntry,
}) {
  return TransferableField.typed<MusicLibraryEntry>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as MusicLibraryEntry,
    read: read,
    write: write,
  );
}

final musicUniversalTransferableFields =
    TransferableField.universalForTyped<MusicLibraryEntry>(
  decode: (value) => value as MusicLibraryEntry,
  readCondition: (item) => item.condition,
  writeCondition: (item, value) =>
      item.copyWith(personal: item.personal.copyWith(condition: value)),
  readPersonalNotes: (item) => item.personalNotes,
  writePersonalNotes: (item, value) => item.copyWith(
    personal: item.personal.copyWith(personalNotes: value),
  ),
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
    ),
  ),
  readSellPriceCents: (item) => item.sellPriceCents?.toString(),
  writeSellPriceCents: (item, value) => item.copyWith(
    personal: item.personal.copyWith(
      sellPriceCents: value == null ? null : int.tryParse(value),
    ),
  ),
  readIndexNumber: (item) => item.indexNumber?.toString(),
  writeIndexNumber: (item, value) => item.copyWith(
    personal: item.personal.copyWith(
      indexNumber: value == null ? null : int.tryParse(value),
    ),
  ),
  readPurchaseDate: (item) => item.purchaseDate?.toIso8601String(),
  writePurchaseDate: (item, value) => item.copyWith(
    personal: item.personal.copyWith(
      purchaseDate: value == null ? null : DateTime.tryParse(value),
    ),
  ),
  readSoldAt: (item) => item.soldAt?.toIso8601String(),
  writeSoldAt: (item, value) => item.copyWith(
    personal: item.personal.copyWith(
      soldAt: value == null ? null : DateTime.tryParse(value),
    ),
  ),
);

final musicTransferableFields = <TransferableField>[
  musicTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
];

const musicAddChrome = LibraryAddChromeConfig(
  mediaReferenceLabel: 'Album',
  trackScopeSummary: 'Tracks and listening activity belong to this album.',
  mediaReferenceHelperLabel: 'Track or save the album itself.',
  editionReferenceHelperLabel: 'Add this album to your library.',
);

Iterable<String?> musicLinkedMetadataValues(MusicAlbum music) => [
      music.artist,
      music.publisher,
      music.countryCode,
      music.language,
      ...music.contributions.map((credit) => credit.displayName),
      ...music.genres,
    ];

MusicAlbum? musicLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is MusicWorkspaceCatalogData ? catalog.music : null;
}

MetadataSearchQuery musicMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = musicLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode ?? metadata?.upc,
    publisher: metadata?.publisher,
    year: metadata?.originalReleaseDate?.year,
    limit: 5,
  );
}

const musicLibraryFacetModule = LibraryFacetModule();
