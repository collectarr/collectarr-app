import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/inspector/inspector_personal_details.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
            ownedItem: OwnedItem(
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

    await tester.pumpAndSettle();

    expect(find.text('2 copies in collection'), findsOneWidget);
    expect(find.text('Active copy'), findsOneWidget);
    expect(find.text('Selected'), findsOneWidget);
    expect(find.text('Add copy'), findsOneWidget);
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
                itemId: 'movie-1',
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
            ownedItem: OwnedItem(
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

    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Very Fine').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Edit'));
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

    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(FilledButton, 'Save tracking details');
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byType(InspectorTrackingDetailsEditor), findsOneWidget);
    expect(saveButton, findsOneWidget);
  });
}