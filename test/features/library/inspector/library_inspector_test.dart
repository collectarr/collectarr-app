import 'dart:convert';

import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/inspector/inspector_item_images_section.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('inspector section renders title and children', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryInspectorSection(
            title: 'Personal',
            children: [Text('Storage box')],
          ),
        ),
      ),
    );

    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Storage box'), findsOneWidget);
  });

  testWidgets('inspector fact grid renders fact labels and values',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData('Grade', '9.8'),
                LibraryInspectorFactData('Condition', 'Near Mint'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grade'), findsOneWidget);
    expect(find.text('9.8'), findsOneWidget);
    expect(find.text('Condition'), findsOneWidget);
    expect(find.text('Near Mint'), findsOneWidget);
  });

  testWidgets('personal section shows cover price for non-comic items',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorPersonalSection(
            entry: LibraryWorkspaceEntry(
              id: 'movie-1',
              mediaType: 'movie',
              title: 'Blade Runner 2049',
              pricePaidCents: 1299,
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            ownedItem: OwnedItem(
              id: 'owned-1',
              itemId: 'movie-1',
              purchaseDate: DateTime.utc(2026, 5, 11),
              pricePaidCents: 1299,
              coverPriceCents: 1599,
              soldAt: DateTime.utc(2026, 5, 20),
              sellPriceCents: 1899,
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            accent: Colors.orange,
            kind: 'movie',
          ),
        ),
      ),
    );

    expect(find.text('Cover price'), findsOneWidget);
    expect(find.text('USD 15.99'), findsOneWidget);
    expect(find.text('Profit / Loss'), findsOneWidget);
    expect(find.text('USD 6.00'), findsOneWidget);
  });

  testWidgets(
      'personal section labels digital ownership and hides physical-only facts',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorPersonalSection(
            entry: LibraryWorkspaceEntry(
              id: 'movie-1',
              mediaType: 'movie',
              title: 'Blade Runner 2049',
              variant: 'Digital',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            ownedItem: OwnedItem(
              id: 'owned-1',
              itemId: 'movie-1',
              isDigital: true,
              pricePaidCents: 1299,
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            accent: Colors.orange,
            kind: 'movie',
          ),
        ),
      ),
    );

    expect(find.text('Ownership'), findsOneWidget);
    expect(find.text('Digital copy'), findsOneWidget);
    expect(find.text('Condition'), findsNothing);
    expect(find.text('Grade'), findsNothing);
    expect(find.text('Storage'), findsNothing);
  });

  testWidgets('inspector action bar avoids overflow on narrow widths', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind('book')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 356,
            child: InspectorActionBar(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Fellowship of the Ring',
                isOwned: true,
                isWishlisted: true,
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              onToggleOwned: () {},
              onToggleWishlist: () {},
              onEdit: () {},
              onOpenDetails: () {},
              onCorrectMetadata: () {},
              extraActions: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(Icons.menu_book_outlined, size: 16),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('OWNED'), findsOneWidget);
  });

  testWidgets('book inspector hides the item images section', (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final type = collectarrLibraryTypes.byKind('book')!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Two Towers',
                ownedItemId: 'owned-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: OwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              accent: Colors.orange,
              onAddOwned: () {},
              onRemoveOwned: () {},
              onAddWishlist: () {},
              onRemoveWishlist: () {},
              onEdit: (_) {},
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.byType(InspectorItemImagesSection), findsNothing);
  });

  testWidgets('item images section hides front cover thumbnails', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'front-1',
            ownedItemId: 'owned-1',
            imageType: const Value('front_cover'),
            imageData: base64Encode(const [0, 1, 2, 3]),
            createdAt: DateTime.utc(2026, 5, 23),
          ),
        );
    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'back-1',
            ownedItemId: 'owned-1',
            imageType: const Value('back_cover'),
            imageData: base64Encode(const [4, 5, 6, 7]),
            createdAt: DateTime.utc(2026, 5, 23),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: InspectorItemImagesSection(
              ownedItemId: 'owned-1',
              db: db,
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.textContaining('Back Cover'), findsOneWidget);
    expect(find.text('Front Cover'), findsNothing);
  });

  testWidgets('inspector shows a copy selector when multiple copies exist', (
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
          home: Scaffold(
            body: LibraryInspector(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Return of the King',
                ownedItemId: 'owned-1',
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
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('2 copies in collection'), findsOneWidget);
    expect(find.text('Add copy'), findsOneWidget);
    expect(find.text('Active copy'), findsOneWidget);
  });

  testWidgets('inspector edit uses the selected copy', (tester) async {
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
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
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
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await pumpUntilSettled(tester);
    await tester.tap(find.textContaining('Very Fine').last);
    await pumpUntilSettled(tester);

    await tester.tap(find.byTooltip('Edit metadata and collection fields'));
    await tester.pump();

    expect(editedOwnedItem?.id, 'owned-2');
  });

  testWidgets(
      'inspector hero switches local back-cover affordance with the selected copy',
      (
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
    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'back-owned-2',
            ownedItemId: 'owned-2',
            imageType: const Value('back_cover'),
            imageData: 'AQIDBA==',
            createdAt: DateTime.utc(2026, 5, 23, 11),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryInspector(
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
              db: db,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.widgetWithText(FilledButton, 'Back cover'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'View back'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await pumpUntilSettled(tester);
    await tester.tap(find.textContaining('Very Fine').last);
    await pumpUntilSettled(tester);

    expect(find.widgetWithText(FilledButton, 'View back'), findsOneWidget);
  });
}
