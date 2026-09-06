import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_preferences.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final comicRuntime = comicKindModule.withCatalogMetadata(
    identity: const LibraryKindIdentity(
      kind: CatalogMediaKind.comic,
      singularLabel: 'Comic',
      pluralLabel: 'Comics',
      title: 'Comics',
      icon: Icons.menu_book,
      accent: Colors.red,
      preferencePrefix: 'comics',
    ),
    metadata: const LibraryMetadataCapability(
      defaultProviderId: 'mock',
      providers: [],
    ),
  );

  final mangaRuntime = comicKindModule.withCatalogMetadata(
    identity: const LibraryKindIdentity(
      kind: CatalogMediaKind.comic,
      singularLabel: 'Manga',
      pluralLabel: 'Manga',
      title: 'Manga',
      icon: Icons.auto_stories,
      accent: Colors.orange,
      preferencePrefix: 'manga',
    ),
    metadata: const LibraryMetadataCapability(
      defaultProviderId: 'mock',
      providers: [],
    ),
  );

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
        sortColumn: 'comic.publisher',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        sortRules: [
          LibrarySortRule(
            column: 'comic.publisher',
            ascending: false,
          ),
          LibrarySortRule(
            column: 'comic.title',
            ascending: false,
          ),
        ],
        coverSize: 144,
        sidebarWidth: 280,
        detailsWidth: 390,
        detailsHeight: 244,
        visibleColumns: {
          'comic.title',
          'comic.publisher',
        },
        columnWidths: {
          'comic.title': 320,
          'comic.publisher': 120,
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
    expect(restored.sortColumn, 'comic.publisher');
    expect(restored.sortAscending, isFalse);
    expect(restored.sortRules, [
      const LibrarySortRule(
        column: 'comic.publisher',
        ascending: false,
      ),
      const LibrarySortRule(
        column: 'comic.title',
        ascending: false,
      ),
    ]);
    expect(restored.coverSize, 144);
    expect(restored.sidebarWidth, 280);
    expect(restored.detailsWidth, 390);
    expect(restored.detailsHeight, 244);
    expect(restored.visibleColumns, {
      'comic.title',
      'comic.publisher',
    });
    expect(restored.visibleColumns.toList(), [
      'comic.title',
      'comic.publisher',
    ]);
    expect(restored.columnWidths['comic.title'], 320);
    expect(restored.columnWidths['comic.publisher'], 120);
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

    expect(restored.detailsLayout, LibraryDetailsLayout.right);
    expect(restored.sidebarWidth, kLibrarySidebarDefaultWidth);
    expect(restored.detailsWidth, kLibraryDetailsDefaultWidth);
    expect(restored.detailsHeight, kLibraryDetailsDefaultHeight);
    expect(restored.viewMode, LibraryViewMode.grid);
    expect(restored.sortColumn, 'comic.series');
    expect(
        restored.visibleColumns,
        mangaRuntime.fields.defaultVisibleColumns
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
        sortColumn: 'comic.title',
        sortAscending: true,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 144,
        sidebarWidth: 640,
        detailsWidth: 980,
        detailsHeight: 540,
        visibleColumns: {
          'comic.title',
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
        sortColumn: 'comic.publisher',
        sortAscending: false,
        densityPreset: LibraryWorkspaceDensityPreset.compact,
        coverSize: 144,
        sidebarWidth: 305,
        detailsWidth: 430,
        detailsHeight: 260,
        visibleColumns: {
          'comic.title',
          'comic.publisher',
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
          'comic.publisher',
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

    expect(comics.sortColumn, 'comic.publisher');
    expect(comics.sortAscending, isFalse);
    expect(comics.detailsLayout, LibraryDetailsLayout.bottom);
    expect(comics.isSidebarVisible, isFalse);

    expect(manga.sortColumn, 'comic.title');
    expect(manga.sortAscending, isTrue);
    expect(manga.detailsLayout, LibraryDetailsLayout.right);
    expect(manga.isSidebarVisible, isTrue);
  });
}
