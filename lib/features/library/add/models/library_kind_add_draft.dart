/// Typed contract for kind-entry manual add draft controllers and state.
abstract interface class LibraryKindAddDraft {
  /// Title of this kind's Catalog Item, stored with its kind-entry values.
  String get catalogTitle;

  set catalogTitle(String value);

  void dispose();
}
