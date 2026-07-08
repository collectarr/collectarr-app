part of '../generic_library_page.dart';

abstract final class LibraryPageNumberNavigationControllerOps {
  static bool canJumpToKindDrilldown(
    GenericLibraryPageState state,
    LibraryProjection? projection,
  ) {
    return state.widget.type.kindUiAdapter.canJumpToSelectedEntry(
      state.widget.type,
      projection,
      activeGroupMode: state._activeGroupMode,
      selectedBucket: state._selectedBucket,
    );
  }

  static Future<void> jumpToNumber(
    GenericLibraryPageState state,
    LibraryProjection projection,
    String rawNumber,
  ) async {
    final normalizedNumber = rawNumber.trim();
    if (normalizedNumber.isEmpty) {
      return;
    }
    final match = _matchNumberInProjection(state, projection, normalizedNumber);
    if (match == null) {
      ScaffoldMessenger.of(state.context).showSnackBar(
        SnackBar(content: Text('Number #$normalizedNumber was not found.')),
      );
      return;
    }
    state._mutateSidebarScope(() {
      state._selectedLetter = null;
      state._linkedMetadataFilter = null;
      state._collectionStatusScope = LibraryCollectionStatusScope.all;
      state._seriesCompletionScope = LibrarySeriesCompletionScope.all;
      state._quickView = null;
      state._filterSelection = LibraryFilterSelection.none;
      state._activeSmartListId = null;
      state._activeSmartListName = null;
      state._searchController.clear();
    });
    state._searchControllerOps.clearSearch();
    state._selectItem(match.entry.id);
  }

  static LibraryProjectionItem? _matchNumberInProjection(
    GenericLibraryPageState state,
    LibraryProjection projection,
    String rawNumber,
  ) {
    final target = int.tryParse(rawNumber.trim());
    if (target == null) {
      return null;
    }
    for (final item in seriesBucketItems(state, projection)) {
      if (_selectionSortNumber(item.entry.itemNumber) == target) {
        return item;
      }
    }
    return null;
  }

  static List<LibraryProjectionItem> seriesBucketItems(
    GenericLibraryPageState state,
    LibraryProjection projection,
  ) {
    return projection.filteredItems.where((item) {
      if (state._activeGroupMode != LibraryGroupMode.series) {
        return false;
      }
      if (item.entry.browseScope != LibraryBrowserScope.title) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  static int? _selectionSortNumber(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }
    final match = RegExp(r'^\s*(\d+)').firstMatch(rawValue);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1)!);
  }

  static String formatNumberRanges(List<int> numbers) {
    if (numbers.isEmpty) {
      return '';
    }
    final sorted = numbers.toList(growable: false)..sort();
    final labels = <String>[];
    var start = sorted.first;
    var end = start;
    for (var index = 1; index < sorted.length; index += 1) {
      final current = sorted[index];
      if (current == end + 1) {
        end = current;
        continue;
      }
      labels.add(start == end ? '#$start' : '#$start-#$end');
      start = current;
      end = current;
    }
    labels.add(start == end ? '#$start' : '#$start-#$end');
    return labels.take(8).join(', ');
  }
}
