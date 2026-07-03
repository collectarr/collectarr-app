import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPageSearchState {
  String query = '';
  String? pinnedItemId;
  LibrarySearchTarget target = LibrarySearchTarget.all;

  void setQuery(String value) {
    final trimmed = value.trim();
    if (query == trimmed && pinnedItemId == null) {
      return;
    }
    query = trimmed;
    pinnedItemId = null;
  }

  void applySuggestion({
    required String title,
    required String id,
  }) {
    final nextQuery = title.trim();
    if (query == nextQuery && pinnedItemId == id) {
      return;
    }
    query = nextQuery;
    pinnedItemId = id;
  }

  void clearSearch() {
    query = '';
    pinnedItemId = null;
    target = LibrarySearchTarget.all;
  }

  void setTarget(LibrarySearchTarget nextTarget) {
    target = nextTarget;
  }
}

final libraryPageSearchStateProvider =
    Provider.autoDispose.family<LibraryPageSearchState, String>(
  (ref, key) => LibraryPageSearchState(),
);
