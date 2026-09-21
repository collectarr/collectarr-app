import 'package:collectarr_app/features/library/config/library_group_mode_category.dart';
import 'package:collectarr_app/features/library/config/library_browser_navigation_policy.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
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
    final actionIds = comicKindToolbar.actions.map((action) => action.id);
    expect(actionIds, contains('comic.jump_to_issue'));
    expect(actionIds, contains('comic.missing_issues'));
  });

  test('browser mode resolution stays in navigation policy', () {
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

    expect(libraryBrowserNavigationPolicy.browserModeForViewState(state),
        LibraryWorkspaceBrowserMode.work);
  });

  test('comic edit capability exposes its dialog builder', () {
    expect(
      comicKindEditCapabilities.presentationCapability.editRegistry
          .builderForScope(LibraryEntityScope.work),
      isNotNull,
    );
  });

  test('release browser mode is owned by navigation policy', () {
    final state = movieKindViewProfile.defaults();
    expect(
      libraryBrowserNavigationPolicy.browserModeForViewState(
        state,
        releaseFolderWorkId: 'movie-1',
      ),
      LibraryWorkspaceBrowserMode.release,
    );
  });
}
