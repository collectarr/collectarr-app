import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final musicRuntime = libraryKindRegistrationForKind(CatalogMediaKind.music);

  setUp(() {
    LibraryWorkspacePreferences.resetCachedChromeForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  test('library workspace preferences persist reusable view settings',
      () async {
    final store = LibraryWorkspacePreferences(musicRuntime);

    await store.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: true,
        sortColumn: 'music.artist_summary',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        sortRules: [
          LibrarySortRule(
            column: 'music.artist_summary',
            ascending: false,
          ),
          LibrarySortRule(
            column: 'music.title',
            ascending: false,
          ),
        ],
        coverSize: 144,
        sidebarWidth: 280,
        detailsWidth: 390,
        detailsHeight: 244,
        visibleColumns: {
          'music.title',
          'music.artist_summary',
        },
        columnWidths: {
          'music.title': 320,
          'music.artist_summary': 120,
        },
      ),
    );

    final restored = await store.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(restored.viewMode, LibraryViewMode.list);
    expect(restored.detailsLayout, LibraryDetailsLayout.bottom);
    expect(restored.sortColumn, 'music.artist_summary');
    expect(restored.sortAscending, isFalse);
    expect(restored.sortRules, [
      const LibrarySortRule(
        column: 'music.artist_summary',
        ascending: false,
      ),
      const LibrarySortRule(
        column: 'music.title',
        ascending: false,
      ),
    ]);
    expect(restored.coverSize, 144);
    expect(restored.sidebarWidth, 280);
    expect(restored.detailsWidth, 390);
    expect(restored.detailsHeight, 244);
    expect(restored.visibleColumns, {
      'music.title',
      'music.artist_summary',
    });
    expect(restored.visibleColumns.toList(), [
      'music.title',
      'music.artist_summary',
    ]);
    expect(restored.columnWidths['music.title'], 320);
    expect(restored.columnWidths['music.artist_summary'], 120);
  });

  test('library workspace preferences keep pane widths beyond the old caps',
      () async {
    final store = LibraryWorkspacePreferences(musicRuntime);

    await store.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        isSidebarVisible: true,
        sortColumn: 'music.title',
        sortAscending: true,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 144,
        sidebarWidth: 640,
        detailsWidth: 980,
        detailsHeight: 540,
        visibleColumns: {
          'music.title',
          'comic.issue_number',
        },
        columnWidths: {},
      ),
    );

    final restored = await store.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(restored.sidebarWidth, 640);
    expect(restored.detailsWidth, 980);
    expect(restored.detailsHeight, 540);
  });
}
