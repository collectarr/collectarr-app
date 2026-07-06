import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  testWidgets('detail page shows copy selector when multiple copies exist', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('book')!;
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'book-1',
            condition: const Value('Near Mint'),
            updatedAt: DateTime.utc(2026, 5, 23, 10),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-2',
            itemId: 'book-1',
            condition: const Value('Very Fine'),
            updatedAt: DateTime.utc(2026, 5, 23, 11),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: LibraryDetailPage(
            type: type,
            entry: LibraryWorkspaceEntry(
              id: 'book-1',
              mediaType: 'book',
              title: 'The Return of the King',
              ownedItemId: 'owned-1',
              isOwned: true,
              updatedAt: DateTime.utc(2026, 5, 23),
            ),
            ownedItem: testOwnedItem(
              id: 'owned-1',
              itemId: 'book-1',
              condition: 'Near Mint',
              updatedAt: DateTime.utc(2026, 5, 23, 10),
            ),
            accent: Colors.orange,
            onAddOwned: () {},
            onRemoveOwned: () {},
            onAddWishlist: () {},
            onRemoveWishlist: () {},
            onEdit: (_) {},
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.byType(AppBar), findsNothing);
    expect(find.byKey(const ValueKey('detail-toolbar-copy-menu')), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Selected'), findsOneWidget);
    expect(find.text('Add copy'), findsNothing);
  });

  testWidgets('detail page edit uses the selected copy', (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('book')!;
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-1',
            itemId: 'book-1',
            condition: const Value('Near Mint'),
            updatedAt: DateTime.utc(2026, 5, 23, 10),
          ),
        );
    await db.into(db.ownedItemsCache).insert(
          OwnedItemsCacheCompanion.insert(
            id: 'owned-2',
            itemId: 'book-1',
            condition: const Value('Very Fine'),
            updatedAt: DateTime.utc(2026, 5, 23, 11),
          ),
        );
    OwnedItem? editedOwnedItem;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(db),
          trackingEntriesProvider.overrideWith(
            (ref) async => [
              TrackingEntry(
                id: 'tracking-1',
                catalogRef: testCatalogRef('movie-1', kind: 'movie'),
                sourceType: 'digital',
                status: 'Watching',
                rating: 8,
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
            ],
          ),
        ],
        child: MaterialApp(
          home: LibraryDetailPage(
            type: type,
            entry: LibraryWorkspaceEntry(
              id: 'book-1',
              mediaType: 'book',
              title: 'The Return of the King',
              ownedItemId: 'owned-1',
              isOwned: true,
              updatedAt: DateTime.utc(2026, 5, 23),
            ),
            ownedItem: testOwnedItem(
              id: 'owned-1',
              itemId: 'book-1',
              condition: 'Near Mint',
              updatedAt: DateTime.utc(2026, 5, 23, 10),
            ),
            accent: Colors.orange,
            onAddOwned: () {},
            onRemoveOwned: () {},
            onAddWishlist: () {},
            onRemoveWishlist: () {},
            onEdit: (ownedItem) => editedOwnedItem = ownedItem,
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    final copyMenu = tester.widget<LibraryDenseMenuButton<dynamic>>(
      find.byKey(const ValueKey('detail-toolbar-copy-menu')),
    );
    final alternateCopyEntry = copyMenu.entries.firstWhere(
      (entry) => !entry.label.startsWith('Viewing '),
    );
    final dynamic dynamicCopyMenu = copyMenu;
    // ignore: avoid_dynamic_calls
    dynamicCopyMenu.onSelected(alternateCopyEntry.value);
    await pumpUntilSettled(tester);

    await tester.tap(find.text('Edit').first);
    await tester.pump();

    expect(editedOwnedItem?.id, 'owned-2');
  });

  testWidgets('detail page shows tracking editor for tracked-only items',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('movie')!;
    await db.into(db.trackingEntriesCache).insert(
          TrackingEntriesCacheCompanion.insert(
            id: 'tracking-1',
            itemId: 'movie-1',
            sourceType: const Value('digital'),
            status: const Value('Watching'),
            rating: const Value(8),
            updatedAt: DateTime.utc(2026, 5, 23),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: LibraryDetailPage(
            type: type,
            entry: LibraryWorkspaceEntry(
              id: 'movie-1',
              mediaType: 'movie',
              title: 'Dune',
              isTracked: true,
              updatedAt: DateTime.utc(2026, 5, 23),
            ),
            ownedItem: null,
            accent: Colors.orange,
            onAddOwned: () {},
            onRemoveOwned: () {},
            onAddWishlist: () {},
            onRemoveWishlist: () {},
            onEdit: (_) {},
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    final saveButton = find.widgetWithText(FilledButton, 'Apply tracking changes');
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find
          .descendant(
            of: find.byType(LibraryDetailPage),
            matching: find.byType(Scrollable),
          )
          .last,
    );
    await pumpUntilSettled(tester);

    expect(find.byType(InspectorTrackingDetailsEditor), findsOneWidget);
    expect(saveButton, findsOneWidget);
  });
}
