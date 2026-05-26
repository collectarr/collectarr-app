import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selectionRangeItemIds returns inclusive forward and backward ranges', () {
    const ordered = ['a', 'b', 'c', 'd', 'e'];

    expect(
      selectionRangeItemIds(ordered, anchorId: 'b', targetId: 'd'),
      {'b', 'c', 'd'},
    );
    expect(
      selectionRangeItemIds(ordered, anchorId: 'd', targetId: 'b'),
      {'b', 'c', 'd'},
    );
  });

  test('selectionRangeItemIds falls back to target when anchor is missing', () {
    const ordered = ['a', 'b', 'c'];

    expect(
      selectionRangeItemIds(ordered, anchorId: 'missing', targetId: 'c'),
      {'c'},
    );
  });

  test('selection state merge keeps existing ids and adds new ones', () {
    final state = LibrarySelectionState.empty().merge(['a', 'b']);
    final merged = state.merge(['b', 'c']);

    expect(merged.itemIds, {'a', 'b', 'c'});
    expect(merged.enabled, isTrue);
  });

  test('context menu selection preserves an existing multi-selection', () {
    expect(
      contextMenuSelectionItemIds({'a', 'b', 'c'}, clickedId: 'b'),
      {'a', 'b', 'c'},
    );
  });

  test('context menu selection collapses to clicked item when needed', () {
    expect(
      contextMenuSelectionItemIds({'a', 'b', 'c'}, clickedId: 'd'),
      {'d'},
    );
    expect(
      contextMenuSelectionItemIds({'a'}, clickedId: 'a'),
      {'a'},
    );
  });
}