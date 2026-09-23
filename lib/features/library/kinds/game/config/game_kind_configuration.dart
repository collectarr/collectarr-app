import '../game_module_dependencies.dart';
import '../edit/game_edit_contribution.dart';

const gamePlatformFilterId = LibraryAddFilterId('game.platform');
const gameYearFilterId = LibraryAddFilterId('game.year');

TransferableField gameTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(GameOwnedItem item) read,
  required GameOwnedItem Function(GameOwnedItem item, String? value) write,
  LibraryEntityScope scope = LibraryEntityScope.copy,
}) {
  return TransferableField.typed<GameOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as GameOwnedItem,
    read: read,
    write: write,
  );
}

final gameUniversalTransferableFields =
    TransferableField.universalForTyped<GameOwnedItem>(
  decode: (value) => value as GameOwnedItem,
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

final gameTransferableFields = <TransferableField>[
  gameTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
];

Iterable<String?> gameLinkedMetadataValues(GameCatalogMetadata metadata) => [
      metadata.series,
      metadata.country,
      metadata.releaseRegion,
      metadata.publishers.firstOrNull,
      ...metadata.publishers,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
      ...metadata.genres,
    ];

GameCatalogMetadata? gameLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is GameWorkspaceCatalogData ? catalog.metadata : null;
}

MetadataSearchQuery gameMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = gameLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode,
    publisher: metadata?.publishers.firstOrNull,
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
