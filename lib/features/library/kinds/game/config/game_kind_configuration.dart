import '../game_module_dependencies.dart';
import '../edit/game_edit_contribution.dart';

const gamePlatformFilterId = LibraryAddFilterId('game.platform');
const gameYearFilterId = LibraryAddFilterId('game.year');

TransferableField gameTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(GameLibraryEntry item) read,
  required GameLibraryEntry Function(GameLibraryEntry item, String? value)
      write,
}) {
  return TransferableField.typed<GameLibraryEntry>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    decode: (value) => value as GameLibraryEntry,
    read: read,
    write: write,
  );
}

final gameUniversalTransferableFields =
    TransferableField.universalForTyped<GameLibraryEntry>(
  decode: (value) => value as GameLibraryEntry,
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

final gameTransferableFields = <TransferableField>[
  gameTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
];

Iterable<String?> gameLinkedMetadataValues(GameCatalogMetadata metadata) => [
      metadata.seriesTitle,
      metadata.country,
      metadata.releaseRegion,
      metadata.publisher,
      ...metadata.creators.map((credit) => credit.name),
      ...metadata.genres,
    ];

GameCatalogMetadata? gameLinkedMetadata(LibraryWorkspaceContext source) {
  final catalog = source.kindPresentationData;
  return catalog is GameWorkspaceData ? catalog.metadata : null;
}

MetadataSearchQuery gameMetadataSearchQuery({
  required LibraryWorkspaceContext source,
  required String title,
}) {
  final metadata = gameLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode,
    publisher: metadata?.publisher,
    year: metadata?.releaseDate?.year,
    limit: 5,
  );
}

final gameLibraryFacetModule = TypedLibraryFacetModule<GameWorkspaceDto>(
  getFacetValues: getGameFacetValues,
  externalFacetBucketIdsByMode: {
    'game.genre': GameFacetIds.genre,
    'game.region': GameFacetIds.region,
  },
);
