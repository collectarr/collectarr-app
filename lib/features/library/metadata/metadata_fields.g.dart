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
    key: 'release_date',
    label: 'Release date',
    section: 'item',
    valueType: 'partialDate',
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
    key: 'catalog_number',
    label: 'Catalog number',
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
    key: 'external_links',
    label: 'External links',
    section: 'relations',
    valueType: 'text',
    inputType: 'multiline',
    normalizedValueType: null
  ),
];
