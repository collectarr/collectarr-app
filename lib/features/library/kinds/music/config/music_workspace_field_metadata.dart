import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';

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

  static const storageSummary = LibraryKindFieldMetadata(
    id: 'music.storage_summary',
    label: 'Storage Summary',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'personal.details.media[]',
    sortable: true,
    exportable: true,
  );

  static const storageDevice = LibraryKindFieldMetadata(
    id: 'music.storage_device',
    label: 'Storage Device',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'personal.details.media[].storage_device',
    filterable: true,
    groupable: true,
    exportable: true,
    editable: true,
  );

  static const storageSlot = LibraryKindFieldMetadata(
    id: 'music.storage_slot',
    label: 'Storage Slot',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'personal.details.media[].storage_slot',
    filterable: true,
    groupable: true,
    exportable: true,
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
    discFormatFamily,
    recordingDate,
    recordingMonth,
    recordingYear,
    earliestDiscRecordingDate,
    latestDiscRecordingDate,
    releaseYear,
    signedBy,
    creditContributor,
    creditRole,
    creditInstrument,
    sound,
    spars,
    status,
    storageSummary,
    storageDevice,
    storageSlot,
    recordingLocations,
    trackCount,
    trackComposition,
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
    groupable: true,
    exportable: true,
  );

  static const discFormatFamily = LibraryKindFieldMetadata(
    id: 'music.disc.format_family',
    label: 'Disc Format Family',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].format_family',
    filterable: true,
    groupable: true,
    exportable: true,
  );

  static const recordingDate = LibraryKindFieldMetadata(
    id: 'music.disc.recording_date',
    label: 'Disc Recording Date',
    valueType: LibraryFieldValueType.partialDate,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].recording_date',
    filterable: true,
    groupable: true,
    exportable: true,
  );

  static const recordingMonth = LibraryKindFieldMetadata(
    id: 'music.disc.recording_month',
    label: 'Disc Recording Month',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.derived,
    sourcePath: 'discs[].recording_date.month',
    filterable: true,
    groupable: true,
  );

  static const creditContributor = LibraryKindFieldMetadata(
    id: 'music.credit.contributor',
    label: 'Contributor',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.derived,
    sourcePath: 'credits[].name + discs[].credits[].name',
    searchable: true,
    filterable: true,
    groupable: true,
    exportable: true,
    vocabulary: VocabularyId<String>('music.contributor_name'),
  );

  static const creditRole = LibraryKindFieldMetadata(
    id: 'music.credit.role',
    label: 'Credit Role',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.derived,
    sourcePath: 'credits[].role + discs[].credits[].role',
    filterable: true,
    groupable: true,
    exportable: true,
    vocabulary: VocabularyId<String>('music.credit_role'),
  );

  static const creditInstrument = LibraryKindFieldMetadata(
    id: 'music.credit.instrument',
    label: 'Credit Instrument',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.derived,
    sourcePath: 'credits[].instruments[] + discs[].credits[].instruments[]',
    filterable: true,
    groupable: true,
    exportable: true,
    vocabulary: VocabularyId<String>('music.instrument'),
  );

  static const trackComposition = LibraryKindFieldMetadata(
    id: 'music.track.composition',
    label: 'Track Composition',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].tracks[].composition',
    searchable: true,
    filterable: true,
    groupable: true,
    exportable: true,
  );

  static const originalReleaseYear = LibraryKindFieldMetadata(
    id: 'music.original_release_year',
    label: 'Original Release Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'original_release_date.year',
    filterable: true,
    groupable: true,
  );

  static const recordingYear = LibraryKindFieldMetadata(
    id: 'music.disc.recording_year',
    label: 'Disc Recording Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.derived,
    sourcePath: 'discs[].recording_date.year',
    filterable: true,
    groupable: true,
  );

  static const earliestDiscRecordingDate = LibraryKindFieldMetadata(
    id: 'music.disc.recording_date.earliest',
    label: 'Earliest Disc Recording Date',
    valueType: LibraryFieldValueType.partialDate,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'earliest_disc_recording_date',
    sortable: true,
    exportable: true,
  );

  static const latestDiscRecordingDate = LibraryKindFieldMetadata(
    id: 'music.disc.recording_date.latest',
    label: 'Latest Disc Recording Date',
    valueType: LibraryFieldValueType.partialDate,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'latest_disc_recording_date',
    sortable: true,
    exportable: true,
  );

  static const releaseYear = LibraryKindFieldMetadata(
    id: 'music.release_year',
    label: 'Release Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'release_date.year',
    filterable: true,
    groupable: true,
  );

  static const sound = LibraryKindFieldMetadata(
    id: 'music.sound',
    label: 'Sound',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].sound_types[]',
    filterable: true,
    groupable: true,
  );

  static const spars = LibraryKindFieldMetadata(
    id: 'music.disc.spars',
    label: 'Disc SPARS',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].spars_code',
    filterable: true,
    groupable: true,
  );

  static const recordingLocations = LibraryKindFieldMetadata(
    id: 'music.recording_location',
    label: 'Recording Location',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].recording_locations[]',
    filterable: true,
    groupable: true,
  );

  static const vinylColor = LibraryKindFieldMetadata(
    id: 'music.vinyl_color',
    label: 'Vinyl Color',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].color',
    filterable: true,
    groupable: true,
  );

  static const rpm = LibraryKindFieldMetadata(
    id: 'music.rpm',
    label: 'RPM',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'discs[].rpm',
    filterable: true,
    groupable: true,
  );
}
