/// Typed contract for kind-owned manual add draft controllers and state.
abstract interface class LibraryKindAddDraft {
  /// Title of this kind's Catalog Item, stored with its kind-owned values.
  String get catalogTitle;

  set catalogTitle(String value);

  void dispose();
}
