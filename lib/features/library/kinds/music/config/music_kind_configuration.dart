import '../music_module_dependencies.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';

export 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_facets.dart'
    show musicLibraryFacetModule, musicLibraryFacetDefinitions;

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
}) {
  return TransferableField.typed<MusicLibraryEntry>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    decode: (value) => value as MusicLibraryEntry,
    read: read,
    write: write,
  );
}

final musicUniversalTransferableFields =
    TransferableField.universalForTyped<MusicLibraryEntry>(
  decode: (value) => value as MusicLibraryEntry,
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
      purchaseDateParts: PartialDate.tryParse(value),
    ),
  ),
  readSoldAt: (item) => item.personal.soldAt?.toIso8601String(),
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
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
];

const musicAddChrome = LibraryAddChromeConfig();

Iterable<String?> musicLinkedMetadataValues(MusicAlbum music) => [
      music.artist,
      music.publisher,
      music.countryCode,
      ...music.credits.map((credit) => credit.name),
      ...music.discs.expand(
        (disc) => disc.credits.map((credit) => credit.name),
      ),
      ...music.genres,
    ];

MusicAlbum? musicLinkedMetadata(LibraryWorkspaceContext source) {
  final catalog = source.kindPresentationData;
  return catalog is MusicWorkspaceData ? catalog.music : null;
}

MetadataSearchQuery musicMetadataSearchQuery({
  required LibraryWorkspaceContext source,
  required String title,
}) {
  final metadata = musicLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode,
    publisher: metadata?.publisher,
    year: metadata?.originalReleaseDate?.year,
    limit: 5,
  );
}
