// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: tool/core_contracts/catalog-item-v1.json
// Contract SHA-256: 3c64f33c4316393759ff09fe79c31482aa1d955887978ae4eb2b019893dff8b7
const catalogItemV1SchemaVersion = 1;
const catalogItemV1ContractVersion = '1.0.0';

/// One Catalog Item field: its key, the title Core gives it and, for a
/// list of objects, the object lists each element contains.
class CatalogItemV1Field {
  const CatalogItemV1Field(this.key, {this.title, this.children = const []});

  final String key;
  final String? title;
  final List<CatalogItemV1Field> children;
}

const Map<String, List<CatalogItemV1Field>> catalogItemV1FieldsByKind = {
  'music': [
    CatalogItemV1Field('artist', title: 'Artist'),
    CatalogItemV1Field('artist_credits', title: 'Artist credits'),
    CatalogItemV1Field('back_cover_image_url'),
    CatalogItemV1Field('barcode', title: 'Barcode'),
    CatalogItemV1Field('box_set', title: 'Box set'),
    CatalogItemV1Field('catalog_number', title: 'Catalog number'),
    CatalogItemV1Field('country', title: 'Country'),
    CatalogItemV1Field('cover_image_url', title: 'Cover URL'),
    CatalogItemV1Field('credits', title: 'Credits'),
    CatalogItemV1Field('discs', title: 'Discs', children: [
      CatalogItemV1Field('credits', title: 'Credits'),
      CatalogItemV1Field('tracks', title: 'Tracks'),
    ]),
    CatalogItemV1Field('external_links', title: 'External links'),
    CatalogItemV1Field('extra', title: 'Extra'),
    CatalogItemV1Field('genres', title: 'Genres'),
    CatalogItemV1Field('label', title: 'Label'),
    CatalogItemV1Field('original_release_date', title: 'Original release date'),
    CatalogItemV1Field('packaging', title: 'Packaging'),
    CatalogItemV1Field('release_date', title: 'Release date'),
    CatalogItemV1Field('sort_title', title: 'Sort title'),
    CatalogItemV1Field('subtitle', title: 'Subtitle'),
    CatalogItemV1Field('thumbnail_image_url', title: 'Thumbnail URL'),
    CatalogItemV1Field('title', title: 'Title'),
  ],
};
