import '../boardgame_module_dependencies.dart';
import '../add/contribution.dart';

const boardGameDesignerFilterId = LibraryAddFilterId('boardgame.designer');
const boardGamePublisherFilterId = LibraryAddFilterId('boardgame.publisher');
const boardGameYearFilterId = LibraryAddFilterId('boardgame.year');

final boardgameUniversalTransferableFields =
    TransferableField.universalForTyped<BoardGameLibraryEntry>(
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

final boardgameTransferableFields = <TransferableField>[
  TransferableField.typed<BoardGameLibraryEntry>(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
  TransferableField.typed<BoardGameLibraryEntry>(
    key: 'isSleeved',
    label: 'Sleeved',
    icon: Icons.shield_outlined,
    type: TransferableFieldType.boolean,
    read: (item) => item.personal.details.isSleeved ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
              details:
                  item.personal.details.copyWith(isSleeved: value == 'true')));
    },
  ),
  TransferableField.typed<BoardGameLibraryEntry>(
    key: 'hasCustomInsert',
    label: 'Custom insert',
    icon: Icons.grid_view_outlined,
    type: TransferableFieldType.boolean,
    read: (item) => item.personal.details.hasCustomInsert ? 'true' : null,
    write: (item, value) {
      return item.copyWith(
          personal: item.personal.copyWith(
        details:
            item.personal.details.copyWith(hasCustomInsert: value == 'true'),
      ));
    },
  ),
];

Iterable<(String, String?)> boardGameLinkedMetadataValues(
  BoardGameMetadata metadata,
) =>
    [
      ('Series', metadata.seriesTitle),
      ('Number', metadata.itemNumber),
      ('Publisher', metadata.publisher),
      ...metadata.publishers.map((publisher) => ('Publisher', publisher)),
      ('Edition', metadata.variantName),
      ...metadata.languages.map((language) => ('Language', language)),
      ...metadata.categories.map((category) => ('Category', category)),
      ...metadata.credits.map((credit) => ('Creator', credit.name)),
    ];

BoardGameMetadata? boardGameLinkedMetadata(LibraryWorkspaceContext source) {
  final catalog = source.kindPresentationData;
  return catalog is BoardGameWorkspaceData ? catalog.metadata : null;
}

MetadataSearchQuery boardGameMetadataSearchQuery({
  required LibraryWorkspaceContext source,
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
  getFacetValues: getBoardGameFacetValues,
);
