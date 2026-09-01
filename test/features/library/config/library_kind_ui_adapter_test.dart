import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comic group mode categories are provided by runtime capabilities', () {
    const modes = [
      'series',
      'grade',
      'publisher',
    ];

    final categories = libraryGroupModeCategories(comicKindModule, modes);

    expect(categories, isNotEmpty);
    expect(
      categories.expand((category) => category.modes),
      containsAll(modes),
    );
  });

  test('comic-only toolbar actions stay in the kind runtime', () {
    final actionIds =
        comicKindModule.toolbar!.actions.map((action) => action.id);
    expect(actionIds, contains('comic.jump_to_issue'));
    expect(actionIds, contains('comic.missing_issues'));
  });

  test('browser mode resolution stays in the hierarchy capability', () {
    final bookModule = bookKindModule;
    final state = LibraryWorkspaceViewState(
      viewMode: LibraryViewMode.grid,
      detailsLayout: LibraryDetailsLayout.bottom,
      isSidebarVisible: true,
      sortId: bookModule.fields.defaultSort,
      sortAscending: true,
      coverSize: 180,
      sidebarWidth: 320,
      detailsWidth: 420,
      detailsHeight: 260,
      visibleColumnIds: bookModule.fields.defaultVisibleColumns,
      columnWidths: const {},
    );

    expect(bookModule.hierarchy.browserModeForViewState(state),
        LibraryWorkspaceBrowserMode.media);
  });

  test('comic edit semantics stay in the edit capability', () {
    expect(comicKindModule.edit.manualAddUsesTitleAsSeries, isTrue);
    expect(comicKindModule.edit.editUsesTitleAsSeries, isTrue);
  });

  test('release browser mode is owned by video hierarchy', () {
    final state = movieKindModule.viewProfile.defaults();
    expect(
      movieKindModule.hierarchy.browserModeForViewState(
        state,
        releaseFolderTitleItemId: 'movie-1',
      ),
      LibraryWorkspaceBrowserMode.releases,
    );
  });
}
