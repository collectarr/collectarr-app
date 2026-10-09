import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Additional kind-owned semantics for workspace fields.
abstract final class GameWorkspaceFieldMetadata {
  static const addedAt = LibraryKindFieldMetadata(
    id: 'game.added_at',
    label: 'Added',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'added_at',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const ageRating = LibraryKindFieldMetadata(
    id: 'game.age_rating',
    label: 'Age Rating',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'age_rating',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const boxOnlyPrice = LibraryKindFieldMetadata(
    id: 'game.box_only_price',
    label: 'Box Only Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'box_only_price',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const cibPrice = LibraryKindFieldMetadata(
    id: 'game.cib_price',
    label: 'CIB Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'cib_price',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const completeness = LibraryKindFieldMetadata(
    id: 'game.completeness',
    label: 'Completeness',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'completeness',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const completionStatus = LibraryKindFieldMetadata(
    id: 'game.completion_status',
    label: 'Completion',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'completion_status',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const condition = LibraryKindFieldMetadata(
    id: 'game.condition',
    label: 'Condition',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'condition',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const coreRegion = LibraryKindFieldMetadata(
    id: 'game.core_region',
    label: 'Region',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'core_region',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const cover = LibraryKindFieldMetadata(
    id: 'game.cover',
    label: 'Cover',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'cover',
  );

  static const developer = LibraryKindFieldMetadata(
    id: 'game.developer',
    label: 'Developer',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'developer',
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const edition = LibraryKindFieldMetadata(
    id: 'game.edition',
    label: 'Edition',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'edition',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const gradedPrice = LibraryKindFieldMetadata(
    id: 'game.graded_price',
    label: 'Graded Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'graded_price',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const hasBox = LibraryKindFieldMetadata(
    id: 'game.has_box',
    label: 'Has Box',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'has_box',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const hasManual = LibraryKindFieldMetadata(
    id: 'game.has_manual',
    label: 'Has Manual',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'has_manual',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const location = LibraryKindFieldMetadata(
    id: 'game.location',
    label: 'Location',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'location',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const loosePrice = LibraryKindFieldMetadata(
    id: 'game.loose_price',
    label: 'Loose Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'loose_price',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const manualOnlyPrice = LibraryKindFieldMetadata(
    id: 'game.manual_only_price',
    label: 'Manual Only Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'manual_only_price',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const newPrice = LibraryKindFieldMetadata(
    id: 'game.new_price',
    label: 'New/Sealed Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'new_price',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const platform = LibraryKindFieldMetadata(
    id: 'game.platform',
    label: 'Platform',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'platform',
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const pricePaid = LibraryKindFieldMetadata(
    id: 'game.price_paid',
    label: 'Purchase Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'price_paid',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const priceChartingId = LibraryKindFieldMetadata(
    id: 'game.pricecharting_id',
    label: 'PriceCharting ID',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'pricecharting_id',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const publisher = LibraryKindFieldMetadata(
    id: 'game.publisher',
    label: 'Publisher',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'publisher',
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const rating = LibraryKindFieldMetadata(
    id: 'game.rating',
    label: 'Rating',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'rating',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const region = LibraryKindFieldMetadata(
    id: 'game.region',
    label: 'Region',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'region',
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const series = LibraryKindFieldMetadata(
    id: 'game.series',
    label: 'Series',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'series',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const status = LibraryKindFieldMetadata(
    id: 'game.status',
    label: 'Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'status',
    sortable: true,
    groupable: true,
  );

  static const title = LibraryKindFieldMetadata(
    id: 'game.title',
    label: 'Title',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'title',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const updatedAt = LibraryKindFieldMetadata(
    id: 'game.updated_at',
    label: 'Updated',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'updated_at',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const valueLocked = LibraryKindFieldMetadata(
    id: 'game.value_locked',
    label: 'Value Locked',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'value_locked',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const wishlist = LibraryKindFieldMetadata(
    id: 'game.wishlist',
    label: 'Wishlist',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'wishlist',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const all = <LibraryKindFieldMetadata>[
    addedAt,
    ageRating,
    boxOnlyPrice,
    cibPrice,
    completeness,
    completionStatus,
    condition,
    coreRegion,
    cover,
    developer,
    edition,
    gradedPrice,
    hasBox,
    hasManual,
    location,
    loosePrice,
    manualOnlyPrice,
    newPrice,
    platform,
    pricePaid,
    priceChartingId,
    publisher,
    rating,
    region,
    series,
    status,
    title,
    updatedAt,
    valueLocked,
    wishlist,
  ];
}
