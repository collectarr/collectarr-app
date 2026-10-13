import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_module.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final comicRuntime = libraryKindRegistrationForKind(CatalogMediaKind.comic);
  final mangaRuntime = libraryKindRegistrationForKind(CatalogMediaKind.manga);
  setUp(() {
    LibraryWorkspacePreferences.resetCachedChromeForTesting();
    SharedPreferences.setMockInitialValues({});
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
          'comic.title',
          'comic.condition',
        },
        columnWidths: {
          'comic.title': 320,
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
  test('sort and chrome preferences stay isolated between libraries', () async {
    final comicsStore = LibraryWorkspacePreferences(comicRuntime);
    final mangaStore = LibraryWorkspacePreferences(mangaRuntime);

    await comicsStore.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        isSidebarVisible: false,
        sortColumn: 'comic.series',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 144,
        sidebarWidth: 305,
        detailsWidth: 430,
        detailsHeight: 260,
        visibleColumns: {
          'comic.title',
          'comic.series',
        },
        columnWidths: {},
      ),
    );

    await mangaStore.write(
      const LibraryWorkspacePreferenceSnapshot(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        isSidebarVisible: true,
        sortColumn: 'comic.title',
        sortAscending: true,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 128,
        sidebarWidth: 250,
        detailsWidth: 340,
        detailsHeight: 300,
        visibleColumns: {
          'comic.title',
          'comic.series',
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

    expect(comics.sortColumn, 'comic.series');
    expect(comics.sortAscending, isFalse);
    expect(comics.detailsLayout, LibraryDetailsLayout.bottom);
    expect(comics.isSidebarVisible, isFalse);

    expect(manga.sortColumn, mangaKindWorkspace.fields.defaultSort.value);
    expect(manga.sortAscending, isTrue);
    expect(manga.detailsLayout, LibraryDetailsLayout.right);
    expect(manga.isSidebarVisible, isTrue);
  });
}
