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
            {bool personal = false, bool groupable = true}) =>
        textField(
            id: LibraryFieldId<GameHardwareKind, String?>('game_hardware.$key'),
            metadata: LibraryKindFieldMetadata(
                id: 'game_hardware.$key',
                label: label,
                valueType: LibraryFieldValueType.text,
                cardinality: LibraryFieldCardinality.one,
                source: personal
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
    (dto) => dto.entry?.createdAt?.toIso8601String(),
    personal: true, groupable: true);
final _modifiedDate = _text('modified_date', 'Modified Date',
    (dto) => dto.entry?.updatedAt.toIso8601String(),
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
final _catalogFields = [
  _title,
  _sortTitle,
  _barcode,
  _releaseDate,
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
LibraryWorkspaceSchema<GameHardwareKind, GameHardwareWorkspaceDto> _schema(
    {required bool personal}) {
  final textFields = [..._catalogFields, if (personal) ..._personalFields];
  final fields = <LibraryFieldDefinition<GameHardwareKind,
      GameHardwareWorkspaceDto, Object?>>[...textFields, if (personal) _value];
  return LibraryWorkspaceSchema(
      kindNamespace: 'game_hardware',
      fields: fields,
      columns: [
        for (final field in fields)
          columnFromField(field, defaultWidth: field == _title ? 260 : 140)
      ],
      sorts: [
        for (final field in textFields)
          sortFromField(field, customCompare: compareNaturalText),
        if (personal) sortFromField(_value, group: 'Value')
      ],
      groups: [
        for (final field
            in textFields.where((field) => field.metadata.groupable))
          LibraryGroupDefinition<GameHardwareKind, GameHardwareWorkspaceDto,
              Object?>(
            id: LibraryGroupId(field.id.value),
            label: field.label,
            category: {
              _completeness,
              _condition,
              _purchaseDate,
              _purchaseStore,
              _valueLocked
            }.contains(field)
                ? 'Value'
                : field.metadata.source == LibraryFieldSource.libraryEntry
                    ? 'Personal'
                    : 'Main',
            getValue: (context) {
              if (field == _tags) return context.dto.entry?.personal.tags;
              if (field == _addedDate || field == _modifiedDate) {
                final date = field == _addedDate
                    ? context.dto.entry?.createdAt
                    : context.dto.entry?.updatedAt;
                return date?.toIso8601String().split('T').first;
              }
              return field.getValue(context);
            },
          )
      ],
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
