import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Additional kind-owned semantics for workspace fields.
abstract final class MangaWorkspaceFieldMetadata {
  static const addedAt = LibraryKindFieldMetadata(
    id: 'manga.added_at',
    label: 'Added',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'added_at',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const barcode = LibraryKindFieldMetadata(
    id: 'manga.barcode',
    label: 'ISBN / Barcode',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'barcode',
    searchable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const boxSetOuterCondition = LibraryKindFieldMetadata(
    id: 'manga.box_set_outer_condition',
    label: 'Box Set Outer Condition',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'box_set_outer_condition',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const chapterCount = LibraryKindFieldMetadata(
    id: 'manga.chapter_count',
    label: 'Chapter Count',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'chapter_count',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const condition = LibraryKindFieldMetadata(
    id: 'manga.condition',
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
    id: 'manga.cover',
    label: 'Cover',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'cover',
  );

  static const demographic = LibraryKindFieldMetadata(
    id: 'manga.demographic',
    label: 'Demographic',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'demographic',
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const dustJacketCondition = LibraryKindFieldMetadata(
    id: 'manga.dust_jacket_condition',
    label: 'Dust Jacket Condition',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'dust_jacket_condition',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const dustJacketPresent = LibraryKindFieldMetadata(
    id: 'manga.dust_jacket_present',
    label: 'Dust Jacket Present',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'dust_jacket_present',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const editionFormat = LibraryKindFieldMetadata(
    id: 'manga.edition_format',
    label: 'Edition Format',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'edition_format',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const englishTitle = LibraryKindFieldMetadata(
    id: 'manga.english_title',
    label: 'English Title',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'english_title',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const insertsPresent = LibraryKindFieldMetadata(
    id: 'manga.inserts_present',
    label: 'Inserts Present',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'inserts_present',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const localizedEdition = LibraryKindFieldMetadata(
    id: 'manga.localized_edition',
    label: 'Localized Edition',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'localized_edition',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const localizedPublisher = LibraryKindFieldMetadata(
    id: 'manga.localized_publisher',
    label: 'Localized Publisher',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'localized_publisher',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const location = LibraryKindFieldMetadata(
    id: 'manga.location',
    label: 'Location',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'location',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const nativeTitle = LibraryKindFieldMetadata(
    id: 'manga.native_title',
    label: 'Native Title',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'native_title',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const obiStripPresent = LibraryKindFieldMetadata(
    id: 'manga.obi_strip_present',
    label: 'Obi Strip Present',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'obi_strip_present',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const originalPublisher = LibraryKindFieldMetadata(
    id: 'manga.original_publisher',
    label: 'Original Publisher',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'original_publisher',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const pricePaid = LibraryKindFieldMetadata(
    id: 'manga.price_paid',
    label: 'Purchase Price',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'price_paid',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const printing = LibraryKindFieldMetadata(
    id: 'manga.printing',
    label: 'Printing',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'printing',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const publicationStatus = LibraryKindFieldMetadata(
    id: 'manga.publication_status',
    label: 'Publication Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'publication_status',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const rating = LibraryKindFieldMetadata(
    id: 'manga.rating',
    label: 'Rating',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'rating',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const readingDirection = LibraryKindFieldMetadata(
    id: 'manga.reading_direction',
    label: 'Reading Direction',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'reading_direction',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const releaseDate = LibraryKindFieldMetadata(
    id: 'manga.release_date',
    label: 'Release Date',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'release_date',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const romajiTitle = LibraryKindFieldMetadata(
    id: 'manga.romaji_title',
    label: 'Romaji Title',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'romaji_title',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const serializationPlatform = LibraryKindFieldMetadata(
    id: 'manga.serialization_platform',
    label: 'Serialization',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'serialization_platform',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const signedBy = LibraryKindFieldMetadata(
    id: 'manga.signed_by',
    label: 'Signed By',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'signed_by',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const slipcoverPresent = LibraryKindFieldMetadata(
    id: 'manga.slipcover_present',
    label: 'Slipcover Present',
    valueType: LibraryFieldValueType.boolean,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'slipcover_present',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const status = LibraryKindFieldMetadata(
    id: 'manga.status',
    label: 'Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'status',
    sortable: true,
    groupable: true,
  );

  static const title = LibraryKindFieldMetadata(
    id: 'manga.title',
    label: 'Title',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'title',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const totalVolumes = LibraryKindFieldMetadata(
    id: 'manga.total_volumes',
    label: 'Total Volumes',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'total_volumes',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const translator = LibraryKindFieldMetadata(
    id: 'manga.translator',
    label: 'Translator',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'translator',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const updatedAt = LibraryKindFieldMetadata(
    id: 'manga.updated_at',
    label: 'Updated',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'updated_at',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const volumeNumber = LibraryKindFieldMetadata(
    id: 'manga.volume_number',
    label: 'Volume Number',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'volume_number',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const wishlist = LibraryKindFieldMetadata(
    id: 'manga.wishlist',
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
    barcode,
    boxSetOuterCondition,
    chapterCount,
    condition,
    cover,
    character,
    country,
    demographic,
    dustJacketCondition,
    dustJacketPresent,
    editionFormat,
    englishTitle,
    genre,
    insertsPresent,
    language,
    localizedEdition,
    localizedPublisher,
    location,
    nativeTitle,
    obiStripPresent,
    originalPublisher,
    pricePaid,
    printing,
    publicationStatus,
    rating,
    readingDirection,
    releaseDate,
    releaseYear,
    romajiTitle,
    serializationPlatform,
    signedBy,
    slipcoverPresent,
    status,
    theme,
    title,
    totalVolumes,
    translator,
    updatedAt,
    volumeNumber,
    wishlist,
  ];

  static const character = LibraryKindFieldMetadata(
    id: 'manga.character',
    label: 'Character',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'characters[].name',
    filterable: true,
  );

  static const genre = LibraryKindFieldMetadata(
    id: 'manga.genre',
    label: 'Genre',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'genres[]',
    filterable: true,
  );

  static const theme = LibraryKindFieldMetadata(
    id: 'manga.theme',
    label: 'Theme',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.many,
    source: LibraryFieldSource.catalog,
    sourcePath: 'themes[]',
    filterable: true,
  );

  static const country = LibraryKindFieldMetadata(
    id: 'manga.country',
    label: 'Country',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'country',
    filterable: true,
  );

  static const language = LibraryKindFieldMetadata(
    id: 'manga.language',
    label: 'Language',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'language',
    filterable: true,
  );

  static const releaseYear = LibraryKindFieldMetadata(
    id: 'manga.release_year',
    label: 'Release Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'release_date.year',
    filterable: true,
  );
}
