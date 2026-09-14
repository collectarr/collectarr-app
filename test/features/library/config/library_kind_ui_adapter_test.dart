import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comic group mode categories are provided by registration capabilities',
      () {
    const modes = [
      'series',
      'grade',
      'publisher',
    ];

    final categories = libraryGroupModeCategories(
      const ComicRegistration(),
      modes,
    );

    expect(categories, isNotEmpty);
    expect(
      categories.expand((category) => category.modes),
      containsAll(modes),
    );
  });

  test('comic-only toolbar actions stay in the kind registration', () {
    final actionIds =
        comicKindToolbar.actions.map((action) => action.id);
    expect(actionIds, contains('comic.jump_to_issue'));
    expect(actionIds, contains('comic.missing_issues'));
  });

  test('browser mode resolution stays in the hierarchy capability', () {
    final bookKind = CatalogMediaKind.book;
    final state = LibraryWorkspaceViewState(
      viewMode: LibraryViewMode.grid,
      detailsLayout: LibraryDetailsLayout.bottom,
      isSidebarVisible: true,
      sortId: bookKindWorkspace.fields.defaultSort,
      sortAscending: true,
      coverSize: 180,
      sidebarWidth: 320,
      detailsWidth: 420,
      detailsHeight: 260,
      visibleColumnIds: bookKindWorkspace.fields.defaultVisibleColumns,
      columnWidths: const {},
    );

    expect(libraryHierarchyForKind(bookKind).browserModeForViewState(state),
        LibraryWorkspaceBrowserMode.media);
  });

  test('comic edit capability exposes its dialog builder', () {
    expect(
      comicKindEditCapabilities.presentationCapability.editDialogBuilder,
      isNotNull,
    );
  });

  test('release browser mode is owned by video hierarchy', () {
    final state = movieKindViewProfile.defaults();
    expect(
      movieKindHierarchy.browserModeForViewState(
        state,
        releaseFolderTitleItemId: 'movie-1',
      ),
      LibraryWorkspaceBrowserMode.releases,
    );
  });
}
