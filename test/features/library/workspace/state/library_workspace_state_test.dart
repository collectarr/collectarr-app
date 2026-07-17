import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/state/library_workspace_providers.dart';
import 'package:collectarr_app/features/library/workspace/data/library_workspace_repository.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import '../../../../helpers/test_data_factories.dart';

void main() {
  group('LibraryWorkspaceKey Tests', () {
    test('equality and hashCode work correctly', () {
      final key1 = LibraryWorkspaceKey(
        kind: CatalogMediaKind.comic,
        collectionId: 'c1',
      );
      final key2 = LibraryWorkspaceKey(
        kind: CatalogMediaKind.comic,
        collectionId: 'c1',
      );
      final key3 = LibraryWorkspaceKey(
        kind: CatalogMediaKind.comic,
        collectionId: 'c2',
      );

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
      expect(key1, isNot(equals(key3)));
    });
  });

  group('LibraryFilterState Tests', () {
    test('copyWith and defaults work correctly', () {
      final state = LibraryFilterState();
      expect(state.searchQuery, isEmpty);
      expect(state.sortAscending, isTrue);

      final updated = state.copyWith(
        searchQuery: 'Spider-Man',
        sortAscending: false,
      );
      expect(updated.searchQuery, 'Spider-Man');
      expect(updated.sortAscending, isFalse);
      expect(updated.visibleColumnIds, state.visibleColumnIds);
    });
  });

  group('LibraryFilters Notifier Tests', () {
    test('notifier initializes from registry defaults and updates correctly', () {
      final key = LibraryWorkspaceKey(kind: CatalogMediaKind.comic);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filters = container.read(libraryFiltersProvider(key));
      expect(filters.groupId, equals('series'));
      expect(filters.sortId, equals('title'));

      final notifier = container.read(libraryFiltersProvider(key).notifier);
      notifier.updateSearch('batman');
      notifier.setGroup('publisher');
      notifier.setSort('issue', ascending: false);

      final next = container.read(libraryFiltersProvider(key));
      expect(next.searchQuery, 'batman');
      expect(next.groupId, 'publisher');
      expect(next.sortId, 'issue');
      expect(next.sortAscending, isFalse);
    });
  });

  group('LocalLibraryWorkspaceRepository & display list stream provider Tests', () {
    test('watchEntries streams filtered, sorted results correctly', () async {
      final key = LibraryWorkspaceKey(kind: CatalogMediaKind.comic);

      final mockShelfState = ShelfState(
        entries: [
          testShelfEntry(itemId: '1', kind: 'comic', title: 'Batman #1'),
          testShelfEntry(itemId: '2', kind: 'comic', title: 'Amazing Spider-Man #1'),
          testShelfEntry(itemId: '3', kind: 'music', title: 'Random Album'),
        ],
        ownedCount: 3,
        wishlistCount: 0,
        missingGradeCount: 0,
        pricedCount: 0,
        totalPaidCents: 0,
        primaryCurrency: 'USD',
        hasMixedCurrencies: false,
      );

      final container = ProviderContainer(
        overrides: [
          shelfProvider.overrideWithValue(AsyncValue.data(mockShelfState)),
        ],
      );
      addTearDown(container.dispose);

      // Keep provider alive by listening to it
      final subscription = container.listen(
        libraryDisplayListProvider(key),
        (previous, next) {},
      );

      final entries = await container.read(libraryDisplayListProvider(key).future);

      // Should filter out kind: music, keeping only kind: comic
      expect(entries.length, equals(2));
      // By default sorted by title, so Amazing Spider-Man #1 comes first
      expect(entries[0].resolvedTitle, 'Amazing Spider-Man #1');
      expect(entries[1].resolvedTitle, 'Batman #1');

      // Now apply a search query filter
      container.read(libraryFiltersProvider(key).notifier).updateSearch('Batman');
      
      // Wait for next emission
      final filteredEntries = await container.read(libraryDisplayListProvider(key).future);
      expect(filteredEntries.length, equals(1));
      expect(filteredEntries[0].resolvedTitle, 'Batman #1');

      subscription.close();
    });
  });

  group('Grouped entries stream provider Tests', () {
    test('groups entries correctly based on active group mode', () async {
      final key = LibraryWorkspaceKey(kind: CatalogMediaKind.comic);

      final mockShelfState = ShelfState(
        entries: [
          testShelfEntry(itemId: '1', kind: 'comic', title: 'Batman #1'),
          testShelfEntry(itemId: '2', kind: 'comic', title: 'Batman #2'),
          testShelfEntry(itemId: '3', kind: 'comic', title: 'Amazing Spider-Man #1'),
        ],
        ownedCount: 3,
        wishlistCount: 0,
        missingGradeCount: 0,
        pricedCount: 0,
        totalPaidCents: 0,
        primaryCurrency: 'USD',
        hasMixedCurrencies: false,
      );

      final container = ProviderContainer(
        overrides: [
          shelfProvider.overrideWithValue(AsyncValue.data(mockShelfState)),
        ],
      );
      addTearDown(container.dispose);

      // Default grouping for comic is 'series'. Set group to null before reading.
      container.read(libraryFiltersProvider(key).notifier).setGroup(null);

      // Keep both display list and grouped entries provider alive
      final subDisplay = container.listen(
        libraryDisplayListProvider(key),
        (previous, next) {},
      );
      final subGrouped = container.listen(
        libraryGroupedEntriesProvider(key),
        (previous, next) {},
      );

      var groups = await container.read(libraryGroupedEntriesProvider(key).future);
      expect(groups.length, equals(1));
      expect(groups[0].key, equals('_all'));
      expect(groups[0].entries.length, equals(3));

      subGrouped.close();
      subDisplay.close();
    });
  });

  group('LibraryWorkspaceIntentNotifier Tests', () {
    test('intent dispatcher delegates mutations to both filters and view config', () {
      final key = LibraryWorkspaceKey(kind: CatalogMediaKind.comic);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final intent = container.read(libraryWorkspaceIntentProvider(key));
      intent.setViewMode(LibraryViewMode.list);
      intent.setSort('comic.grade');

      final viewConfig = container.read(libraryViewConfigProvider(key));
      final filters = container.read(libraryFiltersProvider(key));

      expect(viewConfig.viewMode, equals(LibraryViewMode.list));
      expect(filters.sortId, equals('comic.grade'));
    });
  });
}
