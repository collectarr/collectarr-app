/// Typed contract for kind-entry manual add draft controllers and state.
abstract interface class LibraryKindAddDraft {
  /// Title of this kind's Catalog Item, stored with its kind-entry values.
  String get catalogTitle;

  set catalogTitle(String value);
}

/// A kind Add draft that owns resources such as text controllers.
abstract interface class LibraryKindAddDraftWithResources
    implements LibraryKindAddDraft {
  void dispose();
}

void disposeLibraryKindAddDraft(LibraryKindAddDraft draft) {
  if (draft is LibraryKindAddDraftWithResources) draft.dispose();
}
