// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Projected from collectarr-core app/catalog/metadata_fields.py via
// `python -m scripts.export_app_edit_fields`. Edit the core registry and
// re-run the generator; presentation nuances live in
// shared_metadata_editing_contract.dart.

/// One generated metadata edit field, sourced from the core registry.
typedef GeneratedMetadataField = ({
  String key,
  String label,
  String section,
  String valueType,
  String inputType,
  String? normalizedValueType,
});

/// The canonical editable scalar fields, projected from the core registry.
const List<GeneratedMetadataField> kGeneratedMetadataFields = [
  (
    key: 'genres',
    label: 'Genres',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: 'string_list'
  ),
  (
    key: 'color',
    label: 'Color',
    section: 'technical',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: 'string'
  ),
  (
    key: 'runtime_minutes',
    label: 'Runtime minutes',
    section: 'publishing',
    valueType: 'integer',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'nr_discs',
    label: 'Number of discs',
    section: 'technical',
    valueType: 'integer',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'screen_ratio',
    label: 'Screen ratio',
    section: 'technical',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'audio_tracks',
    label: 'Audio tracks',
    section: 'technical',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'subtitles',
    label: 'Subtitles',
    section: 'technical',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'layers',
    label: 'Layers',
    section: 'technical',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'platforms',
    label: 'Platforms',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: 'string_list'
  ),
  (
    key: 'identifiers',
    label: 'Identifiers',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'contributors',
    label: 'Contributors',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'mechanics',
    label: 'Mechanics',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'categories',
    label: 'Categories',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'families',
    label: 'Families',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'expansions',
    label: 'Expansions',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'rankings',
    label: 'Rankings',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'designers',
    label: 'Designers',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'artists',
    label: 'Artists',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'publishers',
    label: 'Publishers',
    section: 'publishing',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'themes',
    label: 'Themes',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'languages',
    label: 'Languages',
    section: 'regional',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'characters',
    label: 'Characters',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'original_language',
    label: 'Original language',
    section: 'regional',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'expansion_for',
    label: 'Expansion for',
    section: 'relations',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'recommended_players',
    label: 'Recommended players',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'best_players',
    label: 'Best with players',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'min_playtime_minutes',
    label: 'Minimum play time',
    section: 'item',
    valueType: 'integer',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'max_playtime_minutes',
    label: 'Maximum play time',
    section: 'item',
    valueType: 'integer',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'complexity_weight',
    label: 'Complexity weight',
    section: 'item',
    valueType: 'number',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'bgg_rating',
    label: 'BoardGameGeek rating',
    section: 'item',
    valueType: 'number',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'bgg_rating_count',
    label: 'BoardGameGeek rating count',
    section: 'item',
    valueType: 'integer',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'bgg_rank',
    label: 'BoardGameGeek rank',
    section: 'item',
    valueType: 'integer',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'imprint',
    label: 'Imprint',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'series_group',
    label: 'Series group',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'page_count',
    label: 'Page count',
    section: 'publishing',
    valueType: 'integer',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'first_publication_date',
    label: 'First publication date',
    section: 'publishing',
    valueType: 'partialDate',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'original_publication_date',
    label: 'Original publication date',
    section: 'publishing',
    valueType: 'partialDate',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'subjects',
    label: 'Subjects',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'distributor',
    label: 'Distributor',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'region',
    label: 'Region',
    section: 'regional',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'edition_statement',
    label: 'Edition statement',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'dimensions',
    label: 'Dimensions',
    section: 'technical',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'first_edition',
    label: 'First edition',
    section: 'item',
    valueType: 'boolean',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'audio_length_minutes',
    label: 'Audio length (minutes)',
    section: 'technical',
    valueType: 'integer',
    inputType: 'number',
    normalizedValueType: null
  ),
  (
    key: 'binding',
    label: 'Binding',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'back_cover_image_url',
    label: 'Back cover image URL',
    section: 'artwork',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'crossover',
    label: 'Crossover',
    section: 'artwork',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'toy_subtype',
    label: 'Toy subtype',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'toy_type',
    label: 'Toy type',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'company_roles',
    label: 'Company roles',
    section: 'relations',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'franchise',
    label: 'Franchise',
    section: 'relations',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'display_title',
    label: 'Display title',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'studio',
    label: 'Studio',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'production_companies',
    label: 'Production companies',
    section: 'publishing',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'artist',
    label: 'Artist',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'sort_title',
    label: 'Sort title',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'label',
    label: 'Label',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'original_release_date',
    label: 'Original release date',
    section: 'item',
    valueType: 'partialDate',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'packaging',
    label: 'Packaging',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'extra',
    label: 'Extra',
    section: 'technical',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'box_set',
    label: 'Box set',
    section: 'technical',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'title',
    label: 'Title',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'original_title',
    label: 'Original title',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'localized_title',
    label: 'Localized title',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'title_extension',
    label: 'Title extension',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'sort_key',
    label: 'Sort key',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'search_aliases',
    label: 'Search aliases',
    section: 'item',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'item_number',
    label: 'Item number',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'series_title',
    label: 'Series title',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'edition_title',
    label: 'Edition title',
    section: 'item',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'release_date',
    label: 'Release date',
    section: 'item',
    valueType: 'partialDate',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'publisher',
    label: 'Publisher',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'subtitle',
    label: 'Subtitle',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'barcode',
    label: 'Barcode',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'variant_name',
    label: 'Primary variant',
    section: 'publishing',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'catalog_number',
    label: 'Catalog number',
    section: 'technical',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'release_status',
    label: 'Release status',
    section: 'technical',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'country',
    label: 'Country',
    section: 'regional',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'language',
    label: 'Language',
    section: 'regional',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'age_rating',
    label: 'Age rating',
    section: 'regional',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'audience_rating',
    label: 'Audience rating',
    section: 'regional',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: 'string'
  ),
  (
    key: 'series_tags',
    label: 'Series tags',
    section: 'regional',
    valueType: 'stringList',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'cover_image_url',
    label: 'Cover URL',
    section: 'artwork',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'thumbnail_image_url',
    label: 'Thumbnail URL',
    section: 'artwork',
    valueType: 'text',
    inputType: 'text',
    normalizedValueType: null
  ),
  (
    key: 'synopsis',
    label: 'Synopsis',
    section: 'artwork',
    valueType: 'text',
    inputType: 'multiline',
    normalizedValueType: null
  ),
  (
    key: 'plot_summary',
    label: 'Plot summary',
    section: 'artwork',
    valueType: 'text',
    inputType: 'multiline',
    normalizedValueType: null
  ),
  (
    key: 'plot_description',
    label: 'Plot description',
    section: 'artwork',
    valueType: 'text',
    inputType: 'multiline',
    normalizedValueType: null
  ),
  (
    key: 'trailer_urls',
    label: 'Trailer URLs',
    section: 'relations',
    valueType: 'text',
    inputType: 'multiline',
    normalizedValueType: null
  ),
  (
    key: 'external_links',
    label: 'External links',
    section: 'relations',
    valueType: 'text',
    inputType: 'multiline',
    normalizedValueType: null
  ),
];
