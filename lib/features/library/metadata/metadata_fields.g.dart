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
  (key: 'genres', label: 'Genres', section: 'relations', valueType: 'stringList', inputType: 'text', normalizedValueType: 'string_list'),
  (key: 'platforms', label: 'Platforms', section: 'relations', valueType: 'stringList', inputType: 'text', normalizedValueType: 'string_list'),
  (key: 'color', label: 'Color', section: 'technical', valueType: 'text', inputType: 'text', normalizedValueType: 'string'),
  (key: 'nr_discs', label: 'Number of discs', section: 'technical', valueType: 'integer', inputType: 'number', normalizedValueType: 'integer'),
  (key: 'screen_ratio', label: 'Screen ratio', section: 'technical', valueType: 'text', inputType: 'text', normalizedValueType: 'string'),
  (key: 'audio_tracks', label: 'Audio tracks', section: 'technical', valueType: 'text', inputType: 'text', normalizedValueType: 'string'),
  (key: 'subtitles', label: 'Subtitles', section: 'technical', valueType: 'text', inputType: 'text', normalizedValueType: 'string'),
  (key: 'layers', label: 'Layers', section: 'technical', valueType: 'text', inputType: 'text', normalizedValueType: 'string'),
  (key: 'title', label: 'Title', section: 'item', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'original_title', label: 'Original title', section: 'item', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'localized_title', label: 'Localized title', section: 'item', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'title_extension', label: 'Title extension', section: 'item', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'sort_key', label: 'Sort key', section: 'item', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'search_aliases', label: 'Search aliases', section: 'item', valueType: 'stringList', inputType: 'text', normalizedValueType: null),
  (key: 'item_number', label: 'Item number', section: 'item', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'edition_title', label: 'Edition title', section: 'item', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'release_date', label: 'Release date', section: 'item', valueType: 'date', inputType: 'text', normalizedValueType: null),
  (key: 'publisher', label: 'Publisher', section: 'publishing', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'imprint', label: 'Imprint', section: 'publishing', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'subtitle', label: 'Subtitle', section: 'publishing', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'series_group', label: 'Series group', section: 'publishing', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'barcode', label: 'Barcode', section: 'publishing', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'variant_name', label: 'Primary variant', section: 'publishing', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'page_count', label: 'Page count', section: 'publishing', valueType: 'integer', inputType: 'number', normalizedValueType: null),
  (key: 'runtime_minutes', label: 'Runtime minutes', section: 'publishing', valueType: 'integer', inputType: 'number', normalizedValueType: null),
  (key: 'catalog_number', label: 'Catalog number', section: 'technical', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'release_status', label: 'Release status', section: 'technical', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'country', label: 'Country', section: 'regional', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'language', label: 'Language', section: 'regional', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'age_rating', label: 'Age rating', section: 'regional', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'audience_rating', label: 'Audience rating', section: 'regional', valueType: 'text', inputType: 'text', normalizedValueType: 'string'),
  (key: 'series_tags', label: 'Series tags', section: 'regional', valueType: 'stringList', inputType: 'text', normalizedValueType: null),
  (key: 'cover_image_url', label: 'Cover URL', section: 'artwork', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'thumbnail_image_url', label: 'Thumbnail URL', section: 'artwork', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'synopsis', label: 'Synopsis', section: 'artwork', valueType: 'text', inputType: 'multiline', normalizedValueType: null),
  (key: 'crossover', label: 'Crossover', section: 'artwork', valueType: 'text', inputType: 'text', normalizedValueType: null),
  (key: 'plot_summary', label: 'Plot summary', section: 'artwork', valueType: 'text', inputType: 'multiline', normalizedValueType: null),
  (key: 'plot_description', label: 'Plot description', section: 'artwork', valueType: 'text', inputType: 'multiline', normalizedValueType: null),
  (key: 'trailer_urls', label: 'Trailer URLs', section: 'relations', valueType: 'text', inputType: 'multiline', normalizedValueType: null),
  (key: 'external_links', label: 'External links', section: 'relations', valueType: 'text', inputType: 'multiline', normalizedValueType: null),
];
