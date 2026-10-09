import 'dart:async';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/collection/repositories/smart_list_repository.dart';
import 'package:collectarr_app/features/library/generic/library_filters.dart';
import 'package:collectarr_app/features/library/generic/page/collection_tabs.dart';
import 'package:collectarr_app/features/library/generic/smart_list.dart';
import 'package:collectarr_app/features/library/generic/smart_lists_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = LocalDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  testWidgets('collection tabs select saved views and open their manager', (
    tester,
  ) async {
    final list = await SmartListRepository(db).create(_smartList('Favorites'));
    SmartList? selected;
    var managerOpens = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: SizedBox()),
                LibraryCollectionTabBar(
                  mediaKind: 'music',
                  target: SmartListCriteriaTarget.catalog,
                  activeSmartListId: null,
                  onSmartListSelected: (value) => selected = value,
                  onAllSelected: () => selected = null,
                  accent: const Color(0xFFF2932F),
                  onManageCollections: () async {
                    managerOpens++;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    await tester.tap(find.text('Favorites'));
    expect(selected?.id, list.id);

    await tester.tap(find.byTooltip('Collections'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage Collections'));
    await tester.pumpAndSettle();
    expect(managerOpens, 1);

    await tester.tap(find.byKey(const ValueKey('library-collection-add')));
    await tester.pumpAndSettle();
    expect(managerOpens, 2);
  });

  testWidgets('collection tab drag order is persisted per kind and target', (
    tester,
  ) async {
    final repository = SmartListRepository(db);
    final favorites = await repository.create(_smartList('Favorites'));
    final recentlyAdded = await repository.create(_smartList('Recently Added'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: SizedBox()),
                LibraryCollectionTabBar(
                  mediaKind: 'music',
                  target: SmartListCriteriaTarget.catalog,
                  activeSmartListId: null,
                  onSmartListSelected: (_) {},
                  onAllSelected: () {},
                  accent: const Color(0xFFF2932F),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tabs = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    tabs.onReorderItem!(0, 1);
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList('library.collection_tabs.music.catalog'),
      [recentlyAdded.id, favorites.id],
    );
    expect(
      tester.getTopLeft(find.text('Recently Added')).dx,
      lessThan(tester.getTopLeft(find.text('Favorites')).dx),
    );
  });

  testWidgets('removed active collection returns the library to All', (
    tester,
  ) async {
    final repository = SmartListRepository(db);
    final removed = await repository.create(_smartList('Favorites'));
    await repository.delete(removed.id);
    var allSelected = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: SizedBox()),
                LibraryCollectionTabBar(
                  mediaKind: 'music',
                  target: SmartListCriteriaTarget.catalog,
                  activeSmartListId: removed.id,
                  onSmartListSelected: (_) {},
                  onAllSelected: () => allSelected++,
                  accent: const Color(0xFFF2932F),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(allSelected, 1);
    expect(find.text('All'), findsOneWidget);
  });

  testWidgets('collection manager creates and manages a collection', (
    tester,
  ) async {
    late BuildContext pageContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              pageContext = context;
              return TextButton(
                onPressed: () => unawaited(
                  showSmartListsDialog(
                    context: pageContext,
                    db: db,
                    mediaKind: 'music',
                    currentFilter: LibraryFilterSelection.none,
                    currentTarget: SmartListCriteriaTarget.catalog,
                    collectionManager: true,
                  ),
                ),
                child: const Text('Open manager'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open manager'));
    await tester.pumpAndSettle();

    expect(find.text('Manage Collections'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add Collection'));
    await tester.pumpAndSettle();
    expect(find.text('Add Collection'), findsNWidgets(2));
    await tester.enterText(find.byType(TextField), 'Favorites');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsOneWidget);
    final collections = await SmartListRepository(db).getAll(
      mediaKind: 'music',
      target: SmartListCriteriaTarget.catalog,
    );
    expect(collections.map((item) => item.name), ['Favorites']);

    expect(find.byTooltip('Rename collection'), findsOneWidget);
    expect(find.byTooltip('Delete collection'), findsOneWidget);
    await tester.tap(find.byTooltip('Collection actions'));
    await tester.pumpAndSettle();
    expect(find.text('Use current view'), findsOneWidget);

    await tester.tapAt(tester.getTopLeft(find.text('Manage Collections')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Rename collection'));
    await tester.pumpAndSettle();
    expect(find.text('Rename Collection'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Pinned Albums');
    await tester.tap(find.widgetWithText(FilledButton, 'Rename'));
    await tester.pumpAndSettle();
    expect(find.text('Pinned Albums'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete collection'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Collection'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No collections yet. Add one to create a collection tab.'),
        findsOneWidget);
    expect(
      await SmartListRepository(db).getAll(
        mediaKind: 'music',
        target: SmartListCriteriaTarget.catalog,
      ),
      isEmpty,
    );
  });
}

SmartList _smartList(String name) => SmartList(
      id: '',
      name: name,
      target: SmartListCriteriaTarget.catalog,
      kinds: const ['music'],
    );
