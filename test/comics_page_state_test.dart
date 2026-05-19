import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_page_state.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'comics page state clears selection context for search filters and group changes',
      () {
    final state = ComicsPageUiState.initial()
        .withSelectedGroup('DC')
        .withSelectedItem('comic-1')
        .withSelectionMode(true)
        .withSelectionToggled('comic-1');

    final searched = state.withSearch(' Batman ');
    expect(searched.query, 'Batman');
    expect(searched.selectedGroup, isNull);
    expect(searched.selectedItemId, isNull);

    final filtered = state.withFilterSelection(
      const ComicsFilterSelection(
        ownershipFilter: ComicsOwnershipFilter.all,
        publisher: 'DC',
      ),
    );
    expect(filtered.selectedGroup, isNull);
    expect(filtered.selectedItemId, isNull);
    expect(filtered.selectionState.itemIds, isEmpty);

    final grouped = state.withGroupMode(ComicsShelfGroupMode.publisher);
    expect(grouped.groupMode, ComicsShelfGroupMode.publisher);
    expect(grouped.selectedGroup, isNull);
    expect(grouped.selectedItemId, isNull);
  });

  test('comics page state keeps barcode add focused on the added item', () {
    final state = ComicsPageUiState.initial()
        .withSearch('Superman')
        .withSelectedGroup('DC')
        .withBarcodeAdded('comic-8a');

    expect(state.query, '');
    expect(state.selectedGroup, isNull);
    expect(state.selectedItemId, 'comic-8a');
  });
}
