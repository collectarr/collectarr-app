import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';

/// Additional kind-owned semantics for workspace fields.
abstract final class AnimeWorkspaceFieldMetadata {
  static const addedAt = LibraryKindFieldMetadata(
    id: 'anime.added_at',
    label: 'Added',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'added_at',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const airingStatus = LibraryKindFieldMetadata(
    id: 'anime.airing_status',
    label: 'Airing Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'airing_status',
    searchable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const condition = LibraryKindFieldMetadata(
    id: 'anime.condition',
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
    id: 'anime.cover',
    label: 'Cover',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'cover',
  );

  static const episodeCount = LibraryKindFieldMetadata(
    id: 'anime.episode_count',
    label: 'Episode Count',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'episode_count',
    sortable: true,
    groupable: true,
  );

  static const episodeRuntimeMinutes = LibraryKindFieldMetadata(
    id: 'anime.episode_runtime_minutes',
    label: 'Episode Runtime (m)',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'episode_runtime_minutes',
    sortable: true,
    groupable: true,
  );

  static const location = LibraryKindFieldMetadata(
    id: 'anime.location',
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
    id: 'anime.price_paid',
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
    id: 'anime.publisher',
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
    id: 'anime.rating',
    label: 'Rating',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'rating',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const releaseDate = LibraryKindFieldMetadata(
    id: 'anime.release_date',
    label: 'Release Date',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'release_date',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const releaseYear = LibraryKindFieldMetadata(
    id: 'anime.release_year',
    label: 'Release Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'release_year',
    filterable: true,
    sortable: true,
    groupable: true,
  );

  static const season = LibraryKindFieldMetadata(
    id: 'anime.season',
    label: 'Season',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'season',
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const seasonYear = LibraryKindFieldMetadata(
    id: 'anime.season_year',
    label: 'Season Year',
    valueType: LibraryFieldValueType.number,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'season_year',
    sortable: true,
    groupable: true,
  );

  static const sourceMaterial = LibraryKindFieldMetadata(
    id: 'anime.source_material',
    label: 'Source Material',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'source_material',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const status = LibraryKindFieldMetadata(
    id: 'anime.status',
    label: 'Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'collection_status',
    sortable: true,
    groupable: true,
  );

  static const studio = LibraryKindFieldMetadata(
    id: 'anime.studio',
    label: 'Studio',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'studio',
    filterable: true,
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const title = LibraryKindFieldMetadata(
    id: 'anime.title',
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
    id: 'anime.updated_at',
    label: 'Updated',
    valueType: LibraryFieldValueType.date,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'updated_at',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const watchStatus = LibraryKindFieldMetadata(
    id: 'anime.watch_status',
    label: 'Watch Status',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.libraryEntry,
    sourcePath: 'watch_status',
    sortable: true,
    groupable: true,
    editable: true,
  );

  static const wishlist = LibraryKindFieldMetadata(
    id: 'anime.wishlist',
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
    airingStatus,
    condition,
    country,
    cover,
    episodeCount,
    episodeRuntimeMinutes,
    language,
    location,
    pricePaid,
    publisher,
    rating,
    releaseDate,
    releaseYear,
    season,
    seasonYear,
    series,
    sourceMaterial,
    status,
    studio,
    title,
    updatedAt,
    watchStatus,
    wishlist,
  ];

  static const country = LibraryKindFieldMetadata(
    id: 'anime.country',
    label: 'Country',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'country',
    filterable: true,
  );

  static const language = LibraryKindFieldMetadata(
    id: 'anime.language',
    label: 'Language',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.catalog,
    sourcePath: 'language',
    filterable: true,
  );

  static const series = LibraryKindFieldMetadata(
    id: 'anime.series',
    label: 'Series',
    valueType: LibraryFieldValueType.text,
    cardinality: LibraryFieldCardinality.one,
    source: LibraryFieldSource.derived,
    sourcePath: 'series_title',
    filterable: true,
  );
}
