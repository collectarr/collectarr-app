/// UI identity represented by a library entity reference.
///
/// Catalog Items are canonical records from Core. Collection Items are
/// App-owned rows representing individual physical copies. A collection item
/// references a Catalog Item directly; neither identity implies a Work or
/// Release parent.
enum LibraryEntityScope {
  catalogItem('catalog_item'),
  release('release'),
  collectionItem('collection_item');

  const LibraryEntityScope(this.apiValue);

  final String apiValue;

  static LibraryEntityScope fromApiValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'release' => LibraryEntityScope.release,
      'catalog_item' => LibraryEntityScope.catalogItem,
      'collection_item' => LibraryEntityScope.collectionItem,
      _ => throw FormatException('Unsupported library entity scope: $value'),
    };
  }
}
