import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/dto.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class GameHardwarePersonalWorkspaceFields {
  static final completeness = _text('completeness', 'Completeness',
      (dto) => dto.entry?.personal.details.completeness?.label);
  static final condition =
      _text('condition', 'Condition', (dto) => dto.entry?.personal.condition);
  static final owner =
      _text('owner', 'Owner', (dto) => dto.entry?.personal.ownerLabel);
  static final tags =
      _text('tags', 'Tags', (dto) => dto.entry?.personal.tags.join(', '));
  static final purchaseStore = _text('purchase_store', 'Purchase Store',
      (dto) => dto.entry?.personal.purchaseStore);
  static final purchaseDate = _text('purchase_date', 'Purchase Date',
      (dto) => dto.entry?.personal.purchaseDateParts?.isoString);
  static final index = _text(
      'index', 'Index', (dto) => dto.entry?.personal.indexNumber?.toString(),
      groupable: false);
  static final quantity = _text(
      'quantity', 'Quantity', (dto) => dto.entry?.personal.quantity.toString(),
      groupable: false);
  static final addedDate = _text('added_date', 'Added Date',
      (dto) => dto.entry?.createdAt?.toIso8601String().split('T').first);
  static final modifiedDate = _text('modified_date', 'Modified Date',
      (dto) => dto.entry?.updatedAt.toIso8601String().split('T').first);
  static final notes = _text(
      'notes', 'Notes', (dto) => dto.entry?.personal.personalNotes,
      groupable: false);
  static final valueLocked = _text(
      'value_locked',
      'Value Locked',
      (dto) =>
          dto.entry?.personal.details.valueIsLocked == true ? 'Yes' : 'No');
  static final box = _text('box', 'Box',
      (dto) => dto.entry?.personal.details.hasBox == true ? 'Yes' : 'No',
      groupable: false);
  static final priceChartingId = _text('pricecharting_id', 'PriceCharting ID',
      (dto) => dto.entry?.personal.details.priceChartingId,
      groupable: false);
  static final manual = _text('manual', 'Manual',
      (dto) => dto.entry?.personal.details.hasManual == true ? 'Yes' : 'No',
      groupable: false);
  static final serialNumber = _text('serial_number', 'Serial No.',
      (dto) => dto.entry?.personal.details.serialNumber,
      groupable: false);
  static final purchaseMonth = _text('purchase_month', 'Purchase Month',
      (dto) => _purchaseParts(dto)?.month?.toString().padLeft(2, '0'),
      source: LibraryFieldSource.derived);
  static final purchaseYear = _text('purchase_year', 'Purchase Year',
      (dto) => _purchaseParts(dto)?.year?.toString(),
      source: LibraryFieldSource.derived);
  static final collectionStatus = _text(
      'collection_status',
      'Collection Status',
      (dto) => dto.entry == null
          ? null
          : libraryCollectionStatusFromValue(
                  dto.entry!.personal.collectionStatus)
              .label);
  static final location =
      _text('location', 'Location', (dto) => dto.personal.locationPath);
  static final rating = _text(
      'rating', 'My Rating', (dto) => dto.entry?.personal.rating?.toString());
  static final addedMonth = _text('added_month', 'Added Month',
      (dto) => dto.entry?.createdAt?.month.toString().padLeft(2, '0'),
      source: LibraryFieldSource.derived);
  static final addedYear = _text('added_year', 'Added Year',
      (dto) => dto.entry?.createdAt?.year.toString(),
      source: LibraryFieldSource.derived);
  static final modifiedMonth = _text('modified_month', 'Modified Month',
      (dto) => dto.entry?.updatedAt.month.toString().padLeft(2, '0'),
      source: LibraryFieldSource.derived);
  static final addedDateTime = _text('added_datetime', 'Added Date/Time',
      (dto) => dto.entry?.createdAt?.toIso8601String(),
      source: LibraryFieldSource.derived, groupable: false);
  static final modifiedDateTime = _text('modified_datetime',
      'Modified Date/Time', (dto) => dto.entry?.updatedAt.toIso8601String(),
      source: LibraryFieldSource.derived, groupable: false);

  static final value = moneyField<GameHardwareKind, GameHardwareWorkspaceDto>(
      id: const LibraryFieldId('game_hardware.value'),
      metadata: const LibraryKindFieldMetadata(
          id: 'game_hardware.value',
          label: 'Value',
          valueType: LibraryFieldValueType.number,
          cardinality: LibraryFieldCardinality.one,
          source: LibraryFieldSource.libraryEntry,
          sourcePath: 'market_value_cents',
          sortable: true),
      getValue: (dto) => dto.entry?.personal.marketValueCents);
  static final purchasePrice =
      moneyField<GameHardwareKind, GameHardwareWorkspaceDto>(
          id: const LibraryFieldId('game_hardware.purchase_price'),
          metadata: const LibraryKindFieldMetadata(
              id: 'game_hardware.purchase_price',
              label: 'Purchase Price',
              valueType: LibraryFieldValueType.number,
              cardinality: LibraryFieldCardinality.one,
              source: LibraryFieldSource.libraryEntry,
              sourcePath: 'price_paid_cents',
              sortable: true),
          getValue: (dto) => dto.entry?.personal.pricePaidCents);

  /// Text fields listed in the column chooser and sort menu.
  static final all = [
    completeness,
    condition,
    owner,
    tags,
    purchaseStore,
    purchaseDate,
    purchaseMonth,
    purchaseYear,
    collectionStatus,
    location,
    rating,
    addedMonth,
    addedYear,
    modifiedMonth,
    addedDateTime,
    modifiedDateTime,
    index,
    quantity,
    addedDate,
    modifiedDate,
    notes,
    valueLocked,
    box,
    priceChartingId,
    manual,
    serialNumber,
  ];

  static final money = [value, purchasePrice];
}

LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto, String?>
    _text(String key, String label,
            String? Function(GameHardwareWorkspaceDto dto) getValue,
            {LibraryFieldSource source = LibraryFieldSource.libraryEntry,
            bool groupable = true}) =>
        keyedTextField('game_hardware', key, label, getValue,
            source: source, groupable: groupable);

PartialDate? _purchaseParts(GameHardwareWorkspaceDto dto) =>
    dto.entry?.personal.purchaseDateParts ??
    switch (dto.entry?.personal.purchaseDate) {
      final date? => PartialDate.fromDateTime(date),
      _ => null
    };
