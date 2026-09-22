import '../boardgame_module_dependencies.dart';
import '../add/boardgame_add_contribution.dart';

const boardGameDesignerFilterId = LibraryAddFilterId('boardgame.designer');
const boardGamePublisherFilterId = LibraryAddFilterId('boardgame.publisher');
const boardGameYearFilterId = LibraryAddFilterId('boardgame.year');

TransferableField boardGameTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(BoardGameOwnedItem item) read,
  required BoardGameOwnedItem Function(
    BoardGameOwnedItem item,
    String? value,
  ) write,
  LibraryEntityScope scope = LibraryEntityScope.copy,
}) {
  return TransferableField.typed<BoardGameOwnedItem>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    scope: scope,
    decode: (value) => value as BoardGameOwnedItem,
    read: read,
    write: write,
  );
}

final boardgameUniversalTransferableFields =
    TransferableField.universalForTyped<BoardGameOwnedItem>(
  decode: (value) => value as BoardGameOwnedItem,
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

final boardgameTransferableFields = <TransferableField>[
  boardGameTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.grade,
    write: (item, value) => item.copyWith(grade: value),
  ),
  boardGameTransferField(
    key: 'isSleeved',
    label: 'Sleeved',
    icon: Icons.shield_outlined,
    type: TransferableFieldType.boolean,
    read: (item) => item.details.isSleeved ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
          details: item.details.copyWith(isSleeved: value == 'true'));
    },
  ),
  boardGameTransferField(
    key: 'hasCustomInsert',
    label: 'Custom insert',
    icon: Icons.grid_view_outlined,
    type: TransferableFieldType.boolean,
    read: (item) => item.details.hasCustomInsert ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
        details: item.details.copyWith(hasCustomInsert: value == 'true'),
      );
    },
  ),
];

Iterable<String?> boardGameLinkedMetadataValues(
  BoardGameMetadata metadata,
) =>
    [
      metadata.seriesTitle,
      metadata.series?.seriesTitle,
      metadata.itemNumber,
      metadata.publisher,
      ...metadata.publishers,
      metadata.variant,
      ...metadata.languages,
      ...metadata.categories,
      ...metadata.creators.map((credit) => credit['name']?.toString()),
    ];

BoardGameMetadata? boardGameLinkedMetadata(LibraryWorkspaceSource source) {
  final catalog = source.catalogData;
  return catalog is BoardGameWorkspaceCatalogData ? catalog.metadata : null;
}

MetadataSearchQuery boardGameMetadataSearchQuery({
  required LibraryWorkspaceSource source,
  required String title,
}) {
  final metadata = boardGameLinkedMetadata(source);
  return MetadataSearchQuery(
    query: title,
    barcode: metadata?.barcode,
    issueNumber: metadata?.itemNumber,
    publisher: metadata?.publisher,
    year: metadata?.yearPublished,
    limit: 5,
  );
}

final boardGameLibraryFacetModule =
    TypedLibraryFacetModule<BoardGameWorkspaceDto>(
  loadRows: LibraryPageUtilities.libraryFacetRowsForId,
  getFacetValues: getBoardGameFacetValues,
);
