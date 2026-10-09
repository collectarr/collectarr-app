import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Additional kind-owned semantics for workspace fields.
abstract final class ComicWorkspaceFieldMetadata {
  static const addedAt = LibraryKindFieldMetadata(
    id: 'comic.added_at',
    label: 'Added',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'added_at',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const artist = LibraryKindFieldMetadata(
    id: 'comic.artist',
    label: 'Artist',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'artist',
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const barcode = LibraryKindFieldMetadata(
    id: 'comic.barcode',
    label: 'Barcode',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'barcode',
    searchable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const certificationNumber = LibraryKindFieldMetadata(
    id: 'comic.certification_number',
    label: 'Certification Number',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'certification_number',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const condition = LibraryKindFieldMetadata(
    id: 'comic.condition',
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
    id: 'comic.cover',
    label: 'Cover',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'cover',
  );

  static const coverArtist = LibraryKindFieldMetadata(
    id: 'comic.cover_artist',
    label: 'Cover Artist',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'cover_artist',
    searchable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const coverPrice = LibraryKindFieldMetadata(
    id: 'comic.cover_price',
    label: 'Cover Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'cover_price',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const customLabel = LibraryKindFieldMetadata(
    id: 'comic.custom_label',
    label: 'Custom Label',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'custom_label',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const grade = LibraryKindFieldMetadata(
    id: 'comic.grade',
    label: 'Grade',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'grade',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const graderNotes = LibraryKindFieldMetadata(
    id: 'comic.grader_notes',
    label: 'Grader Notes',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'grader_notes',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const gradingCompany = LibraryKindFieldMetadata(
    id: 'comic.grading_company',
    label: 'Grading Company',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'grading_company',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const keyCategory = LibraryKindFieldMetadata(
    id: 'comic.key_category',
    label: 'Key Category',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'key_category',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const keyComic = LibraryKindFieldMetadata(
    id: 'comic.key_comic',
    label: 'Key Comic',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'key_comic',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const keyReason = LibraryKindFieldMetadata(
    id: 'comic.key_reason',
    label: 'Key Reason',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'key_reason',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const keySeverity = LibraryKindFieldMetadata(
    id: 'comic.key_severity',
    label: 'Key Severity',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'key_severity',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const labelType = LibraryKindFieldMetadata(
    id: 'comic.label_type',
    label: 'Label Type',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'label_type',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const lastBagBoardDate = LibraryKindFieldMetadata(
    id: 'comic.last_bag_board_date',
    label: 'Last Bag & Board Date',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'last_bag_board_date',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const location = LibraryKindFieldMetadata(
    id: 'comic.location',
    label: 'Location',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'location',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const pageQuality = LibraryKindFieldMetadata(
    id: 'comic.page_quality',
    label: 'Page Quality',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'page_quality',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const pricePaid = LibraryKindFieldMetadata(
    id: 'comic.price_paid',
    label: 'Purchase Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'price_paid',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const publisher = LibraryKindFieldMetadata(
    id: 'comic.publisher',
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
    id: 'comic.rating',
    label: 'Rating',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'rating',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const rawOrSlabbed = LibraryKindFieldMetadata(
    id: 'comic.raw_or_slabbed',
    label: 'Raw / Slabbed',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'raw_or_slabbed',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const releaseDate = LibraryKindFieldMetadata(
    id: 'comic.release_date',
    label: 'Release Date',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'release_date',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const signedBy = LibraryKindFieldMetadata(
    id: 'comic.signed_by',
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
    id: 'comic.status',
    label: 'Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'status',
    sortable: true,
    groupable: true,
  );

  static const title = LibraryKindFieldMetadata(
    id: 'comic.title',
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
    id: 'comic.updated_at',
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
    id: 'comic.wishlist',
    label: 'Wishlist',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'wishlist',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const writer = LibraryKindFieldMetadata(
    id: 'comic.writer',
    label: 'Writer',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'writer',
    searchable: true,
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const all = <LibraryKindFieldMetadata>[
    addedAt,
    artist,
    barcode,
    character,
    certificationNumber,
    condition,
    cover,
    coverArtist,
    coverPrice,
    customLabel,
    genre,
    grade,
    graderNotes,
    gradingCompany,
    keyCategory,
    keyComic,
    keyReason,
    keySeverity,
    labelType,
    lastBagBoardDate,
    location,
    pageQuality,
    pricePaid,
    publisher,
    rating,
    rawOrSlabbed,
    releaseDate,
    storyArc,
    signedBy,
    status,
    title,
    updatedAt,
    wishlist,
    writer,
  ];

  static const character = LibraryKindFieldMetadata(
    id: 'comic.character',
    label: 'Character',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'characters[].name',
    filterable: true,
  );

  static const genre = LibraryKindFieldMetadata(
    id: 'comic.genre',
    label: 'Genre',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'genres[]',
    filterable: true,
  );

  static const storyArc = LibraryKindFieldMetadata(
    id: 'comic.story_arc',
    label: 'Story Arc',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'story_arcs[].name',
    filterable: true,
  );
}
