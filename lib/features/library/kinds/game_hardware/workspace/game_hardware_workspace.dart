import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:flutter/widgets.dart';
import 'game_hardware_workspace_groups.dart';
import 'package:collectarr_app/core/utils/natural_text_compare.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_topology.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'game_hardware_workspace_dto.dart';
import 'game_hardware_workspace_projector.dart';

abstract final class GameHardwareKind {}

LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto, String?>
    _text(String key, String label,
            String? Function(GameHardwareWorkspaceDto) read,
            {bool personal = false,
            bool groupable = true,
            bool derived = false}) =>
        textField(
            id: LibraryFieldId<GameHardwareKind, String?>('game_hardware.$key'),
            metadata: LibraryKindFieldMetadata(
                id: 'game_hardware.$key',
                label: label,
                valueType: LibraryFieldValueType.text,
                cardinality: LibraryFieldCardinality.one,
                source: derived
                    ? LibraryFieldSource.derived
                    : personal
                        ? LibraryFieldSource.libraryEntry
                        : LibraryFieldSource.catalog,
                sourcePath: key,
                searchable: true,
                sortable: true,
                groupable: groupable),
            getValue: read);
final _title = _text('title', 'Title', (dto) => dto.metadata.title,
    personal: false, groupable: false);
final _sortTitle = _text('sort_title', 'Sort Title',
    (dto) => dto.metadata.sortKey ?? dto.metadata.title,
    personal: false, groupable: false);
final _barcode = _text('barcode', 'Barcode', (dto) => dto.metadata.barcode,
    personal: false, groupable: false);
final _releaseDate = _text('release_date', 'Release Date',
    (dto) => dto.metadata.releaseDateParts?.isoString,
    personal: false, groupable: true);
final _series = _text('series', 'Series', (dto) => dto.metadata.seriesTitle,
    personal: false, groupable: true);
final _platform = _text('platform', 'Platform', (dto) => dto.metadata.platform,
    personal: false, groupable: true);
final _hardwareType = _text(
    'hardware_type', 'Hardware Type', (dto) => dto.metadata.hardwareType,
    personal: false, groupable: true);
final _completeness = _text('completeness', 'Completeness',
    (dto) => dto.entry?.personal.details.completeness?.label,
    personal: true, groupable: true);
final _condition = _text(
    'condition', 'Condition', (dto) => dto.entry?.personal.condition,
    personal: true, groupable: true);
final _owner = _text('owner', 'Owner', (dto) => dto.entry?.personal.ownerLabel,
    personal: true, groupable: true);
final _tags = _text(
    'tags', 'Tags', (dto) => dto.entry?.personal.tags.join(', '),
    personal: true, groupable: true);
final _purchaseStore = _text('purchase_store', 'Purchase Store',
    (dto) => dto.entry?.personal.purchaseStore,
    personal: true, groupable: true);
final _purchaseDate = _text('purchase_date', 'Purchase Date',
    (dto) => dto.entry?.personal.purchaseDateParts?.isoString,
    personal: true, groupable: true);
final _index = _text(
    'index', 'Index', (dto) => dto.entry?.personal.indexNumber?.toString(),
    personal: true, groupable: false);
final _quantity = _text(
    'quantity', 'Quantity', (dto) => dto.entry?.personal.quantity.toString(),
    personal: true, groupable: false);
final _addedDate = _text('added_date', 'Added Date',
    (dto) => dto.entry?.createdAt?.toIso8601String().split('T').first,
    personal: true, groupable: true);
final _modifiedDate = _text('modified_date', 'Modified Date',
    (dto) => dto.entry?.updatedAt.toIso8601String().split('T').first,
    personal: true, groupable: true);
final _notes = _text(
    'notes', 'Notes', (dto) => dto.entry?.personal.personalNotes,
    personal: true, groupable: false);
final _valueLocked = _text('value_locked', 'Value Locked',
    (dto) => dto.entry?.personal.details.valueIsLocked == true ? 'Yes' : 'No',
    personal: true, groupable: true);
final _box = _text('box', 'Box',
    (dto) => dto.entry?.personal.details.hasBox == true ? 'Yes' : 'No',
    personal: true, groupable: false);
final _pricechartingId = _text('pricecharting_id', 'PriceCharting ID',
    (dto) => dto.entry?.personal.details.priceChartingId,
    personal: true, groupable: false);
final _manual = _text('manual', 'Manual',
    (dto) => dto.entry?.personal.details.hasManual == true ? 'Yes' : 'No',
    personal: true, groupable: false);
final _serialNumber = _text('serial_number', 'Serial No.',
    (dto) => dto.entry?.personal.details.serialNumber,
    personal: true, groupable: false);
final _releaseMonth = _text('release_month', 'Release Month',
    (dto) => dto.metadata.releaseDateParts?.month?.toString().padLeft(2, '0'),
    derived: true);
final _releaseYear = _text('release_year', 'Release Year',
    (dto) => dto.metadata.releaseDateParts?.year?.toString(),
    derived: true);
final _purchaseMonth = _text('purchase_month', 'Purchase Month',
    (dto) => _purchaseParts(dto)?.month?.toString().padLeft(2, '0'),
    personal: true, derived: true);
final _purchaseYear = _text('purchase_year', 'Purchase Year',
    (dto) => _purchaseParts(dto)?.year?.toString(),
    personal: true, derived: true);
final _collectionStatus = _text(
    'collection_status',
    'Collection Status',
    (dto) => dto.entry == null
        ? null
        : libraryCollectionStatusFromValue(dto.entry!.personal.collectionStatus)
            .label,
    personal: true);
final _location = _text(
    'location', 'Location', (dto) => dto.personal.locationPath,
    personal: true);
final _rating = _text(
    'rating', 'My Rating', (dto) => dto.entry?.personal.rating?.toString(),
    personal: true);
final _addedMonth = _text('added_month', 'Added Month',
    (dto) => dto.entry?.createdAt?.month.toString().padLeft(2, '0'),
    personal: true, derived: true);
final _addedYear = _text(
    'added_year', 'Added Year', (dto) => dto.entry?.createdAt?.year.toString(),
    personal: true, derived: true);
final _modifiedMonth = _text('modified_month', 'Modified Month',
    (dto) => dto.entry?.updatedAt.month.toString().padLeft(2, '0'),
    personal: true, derived: true);
final _addedDateTime = _text('added_datetime', 'Added Date/Time',
    (dto) => dto.entry?.createdAt?.toIso8601String(),
    personal: true, groupable: false, derived: true);
final _modifiedDateTime = _text('modified_datetime', 'Modified Date/Time',
    (dto) => dto.entry?.updatedAt.toIso8601String(),
    personal: true, groupable: false, derived: true);
PartialDate? _purchaseParts(GameHardwareWorkspaceDto dto) =>
    dto.entry?.personal.purchaseDateParts ??
    switch (dto.entry?.personal.purchaseDate) {
      final date? => PartialDate.fromDateTime(date),
      _ => null
    };

final _frontImage = _imageField('front_image', 'Device Image', 'front_cover');
final _boxImage = _imageField('box_image', 'Box Image', 'back_cover');
final _hasFront = _imageFlag('has_front', 'Has Device', 'front_cover');
final _hasBoxImage = _imageFlag('has_box', 'Has Box', 'back_cover');
LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto, String?>
    _imageField(String key, String label, String imageType) =>
        LibraryFieldDefinition(
          id: LibraryFieldId('game_hardware.$key'),
          metadata: LibraryKindFieldMetadata(
              id: 'game_hardware.$key',
              label: label,
              valueType: LibraryFieldValueType.text,
              cardinality: LibraryFieldCardinality.one,
              source: LibraryFieldSource.derived,
              sourcePath: 'images.$imageType'),
          getValue: (context) => imageType == 'front_cover'
              ? context.dto.metadata.coverImageUrl
              : null,
        );
LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto, String?>
    _imageFlag(String key, String label, String imageType) =>
        LibraryFieldDefinition(
          id: LibraryFieldId('game_hardware.$key'),
          metadata: LibraryKindFieldMetadata(
              id: 'game_hardware.$key',
              label: label,
              valueType: LibraryFieldValueType.text,
              cardinality: LibraryFieldCardinality.one,
              source: LibraryFieldSource.derived,
              sourcePath: 'images.$imageType',
              sortable: true,
              groupable: true),
          getValue: (context) =>
              gameHardwareWorkspaceImageTypes(context).contains(imageType)
                  ? 'Yes'
                  : 'No',
        );
final _catalogFields = [
  _hasFront,
  _hasBoxImage,
  _title,
  _sortTitle,
  _barcode,
  _releaseDate,
  _releaseMonth,
  _releaseYear,
  _series,
  _platform,
  _hardwareType
];
final _personalFields = [
  _completeness,
  _condition,
  _owner,
  _tags,
  _purchaseStore,
  _purchaseDate,
  _purchaseMonth,
  _purchaseYear,
  _collectionStatus,
  _location,
  _rating,
  _addedMonth,
  _addedYear,
  _modifiedMonth,
  _addedDateTime,
  _modifiedDateTime,
  _index,
  _quantity,
  _addedDate,
  _modifiedDate,
  _notes,
  _valueLocked,
  _box,
  _pricechartingId,
  _manual,
  _serialNumber
];
final _value = moneyField<GameHardwareKind, GameHardwareWorkspaceDto>(
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
final _purchasePrice = moneyField<GameHardwareKind, GameHardwareWorkspaceDto>(
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
String _fieldCategory(
    LibraryFieldDefinition<GameHardwareKind, GameHardwareWorkspaceDto, Object?>
        field) {
  if ({_frontImage, _boxImage, _hasFront, _hasBoxImage}.contains(field)) {
    return 'Images';
  }
  if ({
    _value,
    _purchasePrice,
    _completeness,
    _condition,
    _purchaseDate,
    _purchaseMonth,
    _purchaseYear,
    _purchaseStore,
    _valueLocked,
    _box,
    _pricechartingId,
    _manual
  }.contains(field)) {
    return 'Value';
  }
  if ({_hardwareType, _serialNumber}.contains(field)) {
    return 'Hardware';
  }
  return _personalFields.contains(field) ? 'Personal' : 'Main';
}

LibraryWorkspaceSchema<GameHardwareKind, GameHardwareWorkspaceDto> _schema(
    {required bool personal}) {
  final moneyFields = [_value, _purchasePrice];
  final textFields = [..._catalogFields, if (personal) ..._personalFields];
  final fields = <LibraryFieldDefinition<GameHardwareKind,
      GameHardwareWorkspaceDto, Object?>>[
    ...textFields,
    _frontImage,
    _boxImage,
    if (personal) ...moneyFields
  ];
  return LibraryWorkspaceSchema(
      kindNamespace: 'game_hardware',
      fields: fields,
      columns: [
        for (final (field, type) in [
          (_frontImage, 'front_cover'),
          (_boxImage, 'back_cover')
        ])
          columnFromField(field,
              group: 'Images',
              defaultWidth: 48,
              minWidth: 44,
              allowSortInteraction: false,
              allowGroupInteraction: false,
              cellValue: (context) => SizedBox(
                  width: 32,
                  height: 32,
                  child: LibraryCoverImage(
                      title: context.dto.metadata.title,
                      imageUrl: type == 'front_cover'
                          ? context.dto.metadata.coverImageUrl
                          : null,
                      libraryEntryRef: context.dto.entry == null
                          ? null
                          : LibraryEntryRef(
                              kind: CatalogMediaKind.gameHardware,
                              id: context.dto.entry!.id),
                      localImageType: type,
                      showPlaceholder: false,
                      borderRadius: 0))),
        for (final field in textFields)
          columnFromField(field,
              group: _fieldCategory(field),
              defaultWidth: field == _title ? 260 : 140),
        if (personal)
          for (final field in moneyFields)
            columnFromField(field,
                group: 'Value',
                isNumeric: true,
                cellValue: (context) => Text(AppFormats.current.formatMoney(
                    field.getValue(context),
                    context.dto.entry?.personal.currency))),
      ],
      sorts: [
        for (final field in textFields)
          if (field == _title)
            LibrarySortDefinition<GameHardwareKind, GameHardwareWorkspaceDto>(
                id: LibrarySortId(field.id.value),
                label: field.label,
                compare: (left, right) => compareNaturalText(
                    left.sorting.useSortTitles
                        ? left.dto.metadata.sortKey ?? left.dto.metadata.title
                        : left.dto.metadata.title,
                    right.sorting.useSortTitles
                        ? right.dto.metadata.sortKey ?? right.dto.metadata.title
                        : right.dto.metadata.title))
          else
            sortFromField(field,
                group: _fieldCategory(field),
                customCompare: compareNaturalText),
        if (personal)
          for (final field in moneyFields) sortFromField(field, group: 'Value')
      ],
      groups: gameHardwareWorkspaceGroupDefinitions<GameHardwareKind>(
          includePersonal: personal),
      primaryColumn: _title.id,
      defaultVisibleColumns: {_title.id, _releaseDate.id, _platform.id},
      defaultSort: const LibrarySortId('game_hardware.platform'),
      defaultGroup: const LibraryGroupId<GameHardwareKind, String>(
          'game_hardware.platform'));
}

final gameHardwareKindWorkspace =
    TypedLibraryKindWorkspace<GameHardwareWorkspaceDto>(
        catalogItemWorkspace: TypedLibraryTargetWorkspace(
            fields: _schema(personal: false).toRegistry(),
            projector: const GameHardwareWorkspaceProjector()),
        libraryEntryWorkspace: TypedLibraryTargetWorkspace(
            fields: _schema(personal: true).toRegistry(),
            projector: const GameHardwareWorkspaceProjector()),
        trackingTopology: const LibraryTrackingTopology());
final gameHardwareLibraryFacetModule =
    TypedLibraryFacetModule<GameHardwareWorkspaceDto>(
        getFacetValues: (dto, facetId) => const []);
