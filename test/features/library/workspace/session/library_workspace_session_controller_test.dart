import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/session/library_workspace_session_controller.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

void main() {
  group('LibraryWorkspaceSessionController Tests', () {
    late LibraryWorkspaceSessionController controller;

    setUp(() {
      controller = LibraryWorkspaceSessionController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state has default sub-states', () {
      final state = controller.value;
      expect(state.filters.searchQuery, '');
      expect(state.filters.sortId, null);
      expect(state.filters.groupId, null);
      expect(state.selection.itemIds, isEmpty);
      expect(state.folder.selectedNodeId, null);
      expect(state.asyncState.isLoading, false);
      expect(state.asyncState.error, null);
    });

    test('updateSearch updates search query in filter state', () {
      controller.updateSearch('Spider-Man');
      expect(controller.value.filters.searchQuery, 'Spider-Man');
    });

    test('updateSort updates sortId and sortAscending', () {
      const sortId = LibrarySortId<Object>('title');
      controller.updateSort(sortId, ascending: false);
      expect(controller.value.filters.sortId, sortId);
      expect(controller.value.filters.sortAscending, false);
    });

    test('updateGroup updates groupId in filter state', () {
      const groupId = LibraryGroupId<Object, String>('publisher');
      controller.updateGroup(groupId);
      expect(controller.value.filters.groupId, groupId);
    });

    test('toggleColumn adds and removes visible column IDs', () {
      const columnId = LibraryFieldId<Object, String>('publisher');
      controller.toggleColumn(columnId);
      expect(controller.value.filters.visibleColumnIds, contains(columnId));

      controller.toggleColumn(columnId);
      expect(
          controller.value.filters.visibleColumnIds, isNot(contains(columnId)));
    });

    test('selectItem handles single and multi selection', () {
      controller.selectItem('item-1');
      expect(controller.value.selection.itemIds, {'item-1'});

      // Single select replaces previous selection
      controller.selectItem('item-2');
      expect(controller.value.selection.itemIds, {'item-2'});

      // Multi select toggles / adds to selection
      controller.selectItem('item-3', multiSelect: true);
      expect(controller.value.selection.itemIds, {'item-2', 'item-3'});

      controller.clearSelection();
      expect(controller.value.selection.itemIds, isEmpty);
    });

    test('setFolder updates selected folder node and display mode', () {
      controller.setFolder('folder-123',
          displayMode: LibraryFolderDisplayMode.tree);
      expect(controller.value.folder.selectedNodeId, 'folder-123');
      expect(
          controller.value.folder.displayMode, LibraryFolderDisplayMode.tree);
    });

    test('applyPreset updates viewMode', () {
      controller.applyPreset(LibraryWorkspacePreset.card);
      expect(controller.value.view.viewMode, LibraryViewMode.card);
    });

    test('reload toggles loading state and clears error', () {
      controller.setError('Network failure');
      expect(controller.value.asyncState.error, 'Network failure');

      controller.reload();
      expect(controller.value.asyncState.isLoading, false);
      expect(controller.value.asyncState.error, null);
    });

    test('setError sets async error message', () {
      controller.setError('Failed to fetch items');
      expect(controller.value.asyncState.error, 'Failed to fetch items');
      expect(controller.value.asyncState.isLoading, false);
    });

    test('reset restores initial workspace session state', () {
      controller.updateSearch('Test');
      controller.updateSort(const LibrarySortId<Object>('year'));
      controller.selectItem('item-1');
      controller.setError('Error');

      controller.reset();
      expect(controller.value.filters.searchQuery, '');
      expect(controller.value.filters.sortId, null);
      expect(controller.value.selection.itemIds, isEmpty);
      expect(controller.value.asyncState.error, null);
    });
  });
}
