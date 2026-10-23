import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Additional kind-owned semantics for workspace fields.
abstract final class GameWorkspaceFieldMetadata {
  static const addedAt = LibraryKindFieldMetadata(
    id: 'game.added_at',
    label: 'Added Date',
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
    label: 'Collection Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'completion_status',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const completed = LibraryKindFieldMetadata(
    id: 'game.completed',
    label: 'Completed',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'game_completed',
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

  static const platformIcon = LibraryKindFieldMetadata(
    id: 'game.platform_icon',
    label: 'Platform Icon',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'platform',
  );

  static const hasBack = LibraryKindFieldMetadata(
    id: 'game.has_back',
    label: 'Has Back',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'images.has_back',
    groupable: true,
  );

  static const hasFront = LibraryKindFieldMetadata(
    id: 'game.has_front',
    label: 'Has Front',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'images.has_front',
    groupable: true,
  );

  static const imageType = LibraryKindFieldMetadata(
    id: 'game.image_type',
    label: 'Image Type',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.derived,
    sourcePath: 'images[].image_type',
    groupable: true,
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
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const status = LibraryKindFieldMetadata(
    id: 'game.status',
    label: 'Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'collection_status',
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

  static const audienceRating = LibraryKindFieldMetadata(
    id: 'game.audience_rating',
    label: 'Audience Rating',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'audience_rating',
    groupable: true,
  );

  static const sortTitle = LibraryKindFieldMetadata(
    id: 'game.sort_title',
    label: 'Sort Title',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'sort_title',
    sortable: true,
  );

  static const format = LibraryKindFieldMetadata(
    id: 'game.format',
    label: 'Format',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'physical_format',
    groupable: true,
    sortable: true,
  );

  static const purchaseDate = LibraryKindFieldMetadata(
    id: 'game.purchase_date',
    label: 'Purchase Date',
    valueType: LibraryFieldValueType.partialDate,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'purchase_date_parts',
    groupable: true,
    sortable: true,
  );

  static const purchaseStore = LibraryKindFieldMetadata(
    id: 'game.purchase_store',
    label: 'Purchase Store',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'purchase_store',
    groupable: true,
    sortable: true,
  );

  static const purchaseYear = LibraryKindFieldMetadata(
    id: 'game.purchase_year',
    label: 'Purchase Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'purchase_date_parts.year',
    groupable: true,
  );

  static const value = LibraryKindFieldMetadata(
    id: 'game.value',
    label: 'Value',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'market_value_cents',
    sortable: true,
  );

  static const addedDateTime = LibraryKindFieldMetadata(
    id: 'game.added_datetime',
    label: 'Added Date/Time',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'created_at',
    sortable: true,
  );

  static const addedYear = LibraryKindFieldMetadata(
    id: 'game.added_year',
    label: 'Added Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'created_at.year',
    groupable: true,
  );

  static const modifiedDateTime = LibraryKindFieldMetadata(
    id: 'game.modified_datetime',
    label: 'Modified Date/Time',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'updated_at',
    sortable: true,
  );

  static const completedDate = LibraryKindFieldMetadata(
    id: 'game.completed_date',
    label: 'Completed Date',
    valueType: LibraryFieldValueType.partialDate,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'completed_date',
    groupable: true,
    sortable: true,
  );

  static const completedYear = LibraryKindFieldMetadata(
    id: 'game.completed_year',
    label: 'Completed Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'completed_date.year',
    groupable: true,
  );

  static const index = LibraryKindFieldMetadata(
    id: 'game.index',
    label: 'Index',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'index_number',
    sortable: true,
  );

  static const quantity = LibraryKindFieldMetadata(
    id: 'game.quantity',
    label: 'Quantity',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'quantity',
    sortable: true,
  );

  static const notes = LibraryKindFieldMetadata(
    id: 'game.notes',
    label: 'Notes',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'personal_notes',
    sortable: true,
  );

  static const owner = LibraryKindFieldMetadata(
    id: 'game.owner',
    label: 'Owner',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'owner_label',
    groupable: true,
    sortable: true,
  );

  static const storage = LibraryKindFieldMetadata(
    id: 'game.storage',
    label: 'Storage',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'details.storage_device',
    sortable: true,
  );

  static const tags = LibraryKindFieldMetadata(
    id: 'game.tags',
    label: 'Tags',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'tags[]',
    groupable: true,
  );

  static const all = <LibraryKindFieldMetadata>[
    addedAt,
    addedDateTime,
    addedYear,
    ageRating,
    audienceRating,
    completedDate,
    completedYear,
    format,
    index,
    modifiedDateTime,
    notes,
    owner,
    purchaseDate,
    purchaseStore,
    purchaseYear,
    quantity,
    sortTitle,
    storage,
    tags,
    value,
    boxOnlyPrice,
    cibPrice,
    completed,
    completeness,
    completionStatus,
    condition,
    coreRegion,
    country,
    cover,
    developer,
    edition,
    genre,
    gradedPrice,
    hasBox,
    hasBack,
    hasFront,
    hasManual,
    imageType,
    language,
    location,
    loosePrice,
    manualOnlyPrice,
    newPrice,
    platform,
    platformIcon,
    pricePaid,
    priceChartingId,
    publisher,
    rating,
    region,
    releaseYear,
    series,
    status,
    title,
    updatedAt,
    valueLocked,
    wishlist,
  ];

  static const genre = LibraryKindFieldMetadata(
    id: 'game.genre',
    label: 'Genre',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'genres[]',
    filterable: true,
    groupable: true,
  );

  static const country = LibraryKindFieldMetadata(
    id: 'game.country',
    label: 'Country',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'country',
    filterable: true,
  );

  static const language = LibraryKindFieldMetadata(
    id: 'game.language',
    label: 'Language',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'language',
    filterable: true,
  );

  static const releaseYear = LibraryKindFieldMetadata(
    id: 'game.release_year',
    label: 'Release Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'release_date.year',
    groupable: true,
    filterable: true,
  );
}
