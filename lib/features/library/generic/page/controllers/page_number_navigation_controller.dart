part of '../generic_library_page.dart';

abstract final class LibraryPageNumberNavigationControllerOps {
  static bool canJumpToKindDrilldown(
    GenericLibraryPageState state,
    LibraryProjection? projection,
  ) {
    if (projection == null || state._session.facets.selectedBucket == null) {
      return false;
    }
    final registration = state.widget.type;
    final fields = libraryKindWorkspaceForKind(registration.kind).fields;
    final groupDef = fields.findGroupDefinition(
      fields.decodeGroupId(state._activeGroupMode),
    );
    if (groupDef == null || !groupDef.supportsJump) {
      return false;
    }
    final workspace = libraryKindWorkspaceForKind(registration.kind);
    return projection.allItems.any((item) {
      return workspace.groupValue(item, groupDef.id) ==
              state._session.facets.selectedBucket &&
          _selectionSortNumber(
                libraryCardPresentationForEntry(item).itemNumber,
              ) !=
              null;
    });
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
      state._session.facets.selectedLetter = null;
      state._session.facets.linkedMetadataFilter = null;
      state._session.facets.collectionStatusScope =
          LibraryCollectionStatusScope.all;
      state._session.facets.bucketCompletionScope =
          LibraryBucketCompletionScope.all;
      state._session.facets.quickView = null;
      state._session.selection.filterSelection = LibraryFilterSelection.none;
      state._session.preferences.activeSmartListId = null;
      state._session.preferences.activeSmartListName = null;
      state._searchController.clear();
    });
    state._searchControllerOps.clearSearch();
    state._selectItem(match.node.id);
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
    for (final item in bucketItemsForSelectedBucket(state, projection)) {
      if (_selectionSortNumber(
            libraryCardPresentationForEntry(item).itemNumber,
          ) ==
          target) {
        return item;
      }
    }
    return null;
  }

  static List<LibraryProjectionItem> bucketItemsForSelectedBucket(
    GenericLibraryPageState state,
    LibraryProjection projection,
  ) {
    return projection.filteredItems.where((item) {
      if (!libraryGroupModeSupportsCompletion(
          state.widget.type, state._activeGroupMode)) {
        return false;
      }
      if (item.node.scope != LibraryEntityScope.work) {
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
