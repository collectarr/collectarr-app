import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final comicRuntime = libraryKindRegistrationForKind(CatalogMediaKind.music);
  final mangaRuntime = libraryKindRegistrationForKind(CatalogMediaKind.music);

  setUp(() {
    LibraryWorkspacePreferences.resetCachedChromeForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  test('library workspace preferences persist reusable view settings',
      () async {
    final store = LibraryWorkspacePreferences(comicRuntime);

    await store.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: true,
        sortColumn: 'music.artist',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        sortRules: [
          LibrarySortRule(
            column: 'music.artist',
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
          'music.artist',
        },
        columnWidths: {
          'music.title': 320,
          'music.artist': 120,
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
    expect(restored.sortColumn, 'music.artist');
    expect(restored.sortAscending, isFalse);
    expect(restored.sortRules, [
      const LibrarySortRule(
        column: 'music.artist',
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
      'music.artist',
    });
    expect(restored.visibleColumns.toList(), [
      'music.title',
      'music.artist',
    ]);
    expect(restored.columnWidths['music.title'], 320);
    expect(restored.columnWidths['music.artist'], 120);
  });

  test('workspace chrome size and position are retained per library', () async {
    final comicsStore = LibraryWorkspacePreferences(comicRuntime);
    final mangaStore = LibraryWorkspacePreferences(mangaRuntime);

    await comicsStore.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: true,
        sortColumn: 'comic.condition',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 144,
        sidebarWidth: 305,
        detailsWidth: 430,
        detailsHeight: 260,
        visibleColumns: {
          'music.title',
          'comic.condition',
        },
        columnWidths: {
          'music.title': 320,
        },
      ),
    );

    final restored = await mangaStore.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(restored.detailsLayout, LibraryDetailsLayout.bottom);
    expect(restored.sidebarWidth, kLibrarySidebarDefaultWidth);
    expect(restored.detailsWidth, kLibraryDetailsDefaultWidth);
    expect(restored.detailsHeight, kLibraryDetailsDefaultHeight);
    expect(restored.viewMode, LibraryViewMode.grid);
    expect(restored.sortColumn, mangaKindWorkspace.fields.defaultSort.value);
    expect(
        restored.visibleColumns,
        mangaKindWorkspace.fields.defaultVisibleColumns
            .map((column) => column.value)
            .toSet());
    expect(restored.columnWidths, isEmpty);
  });

  test('library workspace preferences keep pane widths beyond the old caps',
      () async {
    final store = LibraryWorkspacePreferences(comicRuntime);

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

  test('sort and chrome preferences stay isolated between libraries', () async {
    final comicsStore = LibraryWorkspacePreferences(comicRuntime);
    final mangaStore = LibraryWorkspacePreferences(mangaRuntime);

    await comicsStore.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: false,
        sortColumn: 'music.artist',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 144,
        sidebarWidth: 305,
        detailsWidth: 430,
        detailsHeight: 260,
        visibleColumns: {
          'music.title',
          'music.artist',
        },
        columnWidths: {},
      ),
    );

    await mangaStore.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        isSidebarVisible: true,
        sortColumn: 'music.title',
        sortAscending: true,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 128,
        sidebarWidth: 250,
        detailsWidth: 340,
        detailsHeight: 300,
        visibleColumns: {
          'music.title',
          'music.artist',
        },
        columnWidths: {},
      ),
    );

    final comics = await comicsStore.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );
    final manga = await mangaStore.read(
      defaultCoverSize: 128,
      defaultDensityPreset: LibraryWorkspaceDensityPreset.compact,
      minCoverSize: 104,
      maxCoverSize: 188,
    );

    expect(comics.sortColumn, 'music.artist');
    expect(comics.sortAscending, isFalse);
    expect(comics.detailsLayout, LibraryDetailsLayout.bottom);
    expect(comics.isSidebarVisible, isFalse);

    expect(manga.sortColumn, mangaKindWorkspace.fields.defaultSort.value);
    expect(manga.sortAscending, isTrue);
    expect(manga.detailsLayout, LibraryDetailsLayout.right);
    expect(manga.isSidebarVisible, isTrue);
  });
}
