import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Additional kind-owned semantics for workspace fields.
abstract final class MusicWorkspaceFieldMetadata {
  static const addedAt = LibraryKindFieldMetadata(
    id: 'music.added_at',
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
    id: 'music.condition',
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
    id: 'music.cover',
    label: 'Cover',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'cover',
  );

  static const grade = LibraryKindFieldMetadata(
    id: 'music.grade',
    label: 'Grade',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'grade',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const indexNumber = LibraryKindFieldMetadata(
    id: 'music.index_number',
    label: 'Index number',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'index_number',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const lastCleaned = LibraryKindFieldMetadata(
    id: 'music.last_cleaned',
    label: 'Last cleaned',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'last_cleaned',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const lastListened = LibraryKindFieldMetadata(
    id: 'music.last_listened',
    label: 'Last listened',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'last_listened',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const listenCount = LibraryKindFieldMetadata(
    id: 'music.listen_count',
    label: 'Listen count',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'listen_count',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const location = LibraryKindFieldMetadata(
    id: 'music.location',
    label: 'Location',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'location',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const marketValue = LibraryKindFieldMetadata(
    id: 'music.market_value',
    label: 'Market value',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'market_value',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const pricePaid = LibraryKindFieldMetadata(
    id: 'music.price_paid',
    label: 'Purchase Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'price_paid',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const purchaseDate = LibraryKindFieldMetadata(
    id: 'music.purchase_date',
    label: 'Purchase date',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'purchase_date',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const rating = LibraryKindFieldMetadata(
    id: 'music.rating',
    label: 'Rating',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'rating',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const signedBy = LibraryKindFieldMetadata(
    id: 'music.signed_by',
    label: 'Signed By',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'signed_by',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const status = LibraryKindFieldMetadata(
    id: 'music.status',
    label: 'Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'status',
    sortable: true,
    groupable: true,
  );

  static const storage = LibraryKindFieldMetadata(
    id: 'music.storage',
    label: 'Storage',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'storage',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const trackCount = LibraryKindFieldMetadata(
    id: 'music.track_count',
    label: 'Track count',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'track_count',
    sortable: true,
    groupable: true,
  );

  static const updatedAt = LibraryKindFieldMetadata(
    id: 'music.updated_at',
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
    id: 'music.wishlist',
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
    grade,
    isLive,
    indexNumber,
    lastCleaned,
    lastListened,
    listenCount,
    location,
    marketValue,
    pricePaid,
    purchaseDate,
    rating,
    originalReleaseYear,
    recordingYear,
    releaseYear,
    signedBy,
    sound,
    spars,
    status,
    storage,
    recordingLocations,
    trackCount,
    updatedAt,
    vinylColor,
    wishlist,
    rpm,
  ];

  static const isLive = LibraryKindFieldMetadata(
    id: 'music.disc.is_live',
    label: 'Disc Live / Studio',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].is_live',
    filterable: true,
  );

  static const originalReleaseYear = LibraryKindFieldMetadata(
    id: 'music.original_release_year',
    label: 'Original Release Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'original_release_date.year',
    filterable: true,
  );

  static const recordingYear = LibraryKindFieldMetadata(
    id: 'music.disc.recording_year',
    label: 'Disc Recording Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.derived,
    sourcePath: 'discs[].recording_date.year',
    filterable: true,
  );

  static const releaseYear = LibraryKindFieldMetadata(
    id: 'music.release_year',
    label: 'Release Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'release_date.year',
    filterable: true,
  );

  static const sound = LibraryKindFieldMetadata(
    id: 'music.sound',
    label: 'Sound',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].sound_types[]',
    filterable: true,
  );

  static const spars = LibraryKindFieldMetadata(
    id: 'music.disc.spars',
    label: 'Disc SPARS',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].spars_code',
    filterable: true,
  );

  static const recordingLocations = LibraryKindFieldMetadata(
    id: 'music.recording_location',
    label: 'Recording Location',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].recording_locations[]',
    filterable: true,
  );

  static const vinylColor = LibraryKindFieldMetadata(
    id: 'music.vinyl_color',
    label: 'Vinyl Color',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].color',
    filterable: true,
  );

  static const rpm = LibraryKindFieldMetadata(
    id: 'music.rpm',
    label: 'RPM',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].rpm',
    filterable: true,
  );
}
