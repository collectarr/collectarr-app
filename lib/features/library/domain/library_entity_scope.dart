/// UI identity represented by a library entity reference.
///
/// Catalog Items are canonical records from Core. Library Entries are the
/// complete, independently editable records managed by the App. An entry may
/// carry provenance to a Catalog Item; neither identity implies a Work or
/// Release parent.
enum LibraryEntityScope {
  catalogItem('catalog_item'),
  libraryEntry('library_entry');

  const LibraryEntityScope(this.apiValue);

  final String apiValue;

  static LibraryEntityScope fromApiValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'catalog_item' => LibraryEntityScope.catalogItem,
      'library_entry' => LibraryEntityScope.libraryEntry,
      _ => throw FormatException('Unsupported library entity scope: $value'),
    };
  }
}
