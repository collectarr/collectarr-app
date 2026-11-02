import '../game_hardware_module_dependencies.dart';

TransferableField gameHardwareTransferField({
  required String key,
  required String label,
  required IconData icon,
  required TransferableFieldType type,
  required String? Function(GameHardwareLibraryEntry item) read,
  required GameHardwareLibraryEntry Function(
          GameHardwareLibraryEntry item, String? value)
      write,
}) {
  return TransferableField.typed<GameHardwareLibraryEntry>(
    key: key,
    label: label,
    icon: icon,
    type: type,
    decode: (value) => value as GameHardwareLibraryEntry,
    read: read,
    write: write,
  );
}

final gameHardwareUniversalTransferableFields =
    TransferableField.universalForTyped<GameHardwareLibraryEntry>(
  decode: (value) => value as GameHardwareLibraryEntry,
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

final gameHardwareTransferableFields = <TransferableField>[
  gameHardwareTransferField(
    key: 'grade',
    label: 'Grade',
    icon: Icons.workspace_premium_outlined,
    type: TransferableFieldType.text,
    read: (item) => item.personal.grade,
    write: (item, value) =>
        item.copyWith(personal: item.personal.copyWith(grade: value)),
  ),
];

Iterable<String?> gameHardwareLinkedMetadataValues(
        GameHardwareCatalogMetadata metadata) =>
    [metadata.seriesTitle];
GameHardwareCatalogMetadata? gameHardwareLinkedMetadata(
    LibraryWorkspaceContext source) {
  final data = source.kindPresentationData;
  return data is GameHardwareWorkspaceData ? data.metadata : null;
}

MetadataSearchQuery gameHardwareMetadataSearchQuery(
        {required LibraryWorkspaceContext source, required String title}) =>
    MetadataSearchQuery(
        query: title,
        barcode: gameHardwareLinkedMetadata(source)?.barcode,
        limit: 5);
