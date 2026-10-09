import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Additional kind-owned semantics for workspace fields.
abstract final class BoardGameWorkspaceFieldMetadata {
  static const addedAt = LibraryKindFieldMetadata(
    id: 'boardgame.added_at',
    label: 'Added',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'added_at',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const condition = LibraryKindFieldMetadata(
    id: 'boardgame.condition',
    label: 'Condition',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'condition',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const cover = LibraryKindFieldMetadata(
    id: 'boardgame.cover',
    label: 'Cover',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'cover',
  );

  static const designer = LibraryKindFieldMetadata(
    id: 'boardgame.designer',
    label: 'Designer',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'designer',
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const location = LibraryKindFieldMetadata(
    id: 'boardgame.location',
    label: 'Location',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'location',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const pricePaid = LibraryKindFieldMetadata(
    id: 'boardgame.price_paid',
    label: 'Purchase Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'price_paid',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const rating = LibraryKindFieldMetadata(
    id: 'boardgame.rating',
    label: 'Rating',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'rating',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const status = LibraryKindFieldMetadata(
    id: 'boardgame.status',
    label: 'Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'status',
    sortable: true,
    groupable: true,
  );

  static const title = LibraryKindFieldMetadata(
    id: 'boardgame.title',
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
    id: 'boardgame.updated_at',
    label: 'Updated',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'updated_at',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const wishlist = LibraryKindFieldMetadata(
    id: 'boardgame.wishlist',
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
    condition,
    cover,
    designer,
    location,
    pricePaid,
    rating,
    status,
    title,
    updatedAt,
    wishlist,
  ];
}
