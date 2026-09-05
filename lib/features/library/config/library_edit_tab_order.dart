import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';

class LibraryEditSectionRegistry {
  const LibraryEditSectionRegistry();

  static const LibraryEditSectionRegistry instance =
      LibraryEditSectionRegistry();

  int orderOfTab(LibraryEditTabSpec tab) {
    return tab.priority;
  }

  List<LibraryEditTabSpec> orderTabs(Iterable<LibraryEditTabSpec> tabs) {
    final indexedTabs = <_IndexedEditTab>[];
    var index = 0;
    for (final tab in tabs) {
      indexedTabs.add(_IndexedEditTab(index: index, tab: tab));
      index++;
    }
    indexedTabs.sort((left, right) {
      final leftOrder = orderOfTab(left.tab);
      final rightOrder = orderOfTab(right.tab);
      if (leftOrder != rightOrder) {
        return leftOrder.compareTo(rightOrder);
      }
      return left.index.compareTo(right.index);
    });
    return [for (final entry in indexedTabs) entry.tab];
  }
}

class _IndexedEditTab {
  const _IndexedEditTab({
    required this.index,
    required this.tab,
  });

  final int index;
  final LibraryEditTabSpec tab;
}
