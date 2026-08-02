import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factories.dart';

void main() {
  testWidgets(
      'detail hero keeps a back cover affordance when the back image is missing',
      (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'front-only-1',
            ownedItemId: 'owned-1',
            imageType: const Value('front_cover'),
            imageData: base64Decode(base64Encode(const [0, 1, 2, 3])),
            createdAt: DateTime.utc(2026, 5, 23),
          ),
        );

    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.book)!;
    final owned = testOwnedItem(
      id: 'owned-1',
      itemId: 'book-1',
      updatedAt: DateTime.utc(2026, 5, 23),
    );
    final source = ShelfEntry(
      itemId: 'book-1',
      catalogItem: testCatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'The Fellowship of the Ring',
      ),
      ownedItem: owned,
    );
    const node = LibraryTitleNodeRef(titleItemId: 'book-1');
    final dto = const BookWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final bookItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryDetailHero(
              type: type,
              item: bookItem,
              ownedItem: owned,
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('The Fellowship of the Ring'), findsWidgets);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets(
      'detail hero exposes back cover toggle when local back cover exists', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'front-1',
            ownedItemId: 'owned-1',
            imageType: const Value('front_cover'),
            imageData: base64Decode(base64Encode(const [0, 1, 2, 3])),
            createdAt: DateTime.utc(2026, 5, 23),
          ),
        );
    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'back-1',
            ownedItemId: 'owned-1',
            imageType: const Value('back_cover'),
            imageData: base64Decode(base64Encode(const [4, 5, 6, 7])),
            createdAt: DateTime.utc(2026, 5, 23),
          ),
        );

    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.book)!;
    final owned = testOwnedItem(
      id: 'owned-1',
      itemId: 'book-1',
      updatedAt: DateTime.utc(2026, 5, 23),
    );
    final source = ShelfEntry(
      itemId: 'book-1',
      catalogItem: testCatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'The Two Towers',
      ),
      ownedItem: owned,
    );
    const node = LibraryTitleNodeRef(titleItemId: 'book-1');
    final dto = const BookWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final bookItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryDetailHero(
              type: type,
              item: bookItem,
              ownedItem: owned,
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('The Two Towers'), findsWidgets);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('detail hero shows a book author spotlight when creators exist', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.book)!;
    final source = ShelfEntry(
      itemId: 'book-1',
      catalogItem: testCatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'The Return of the King',
        creators: [
          {
            'name': 'J.R.R. Tolkien',
            'role': 'Author',
          },
        ],
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'book-1');
    final dto = const BookWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final bookItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryDetailHero(
              type: type,
              item: bookItem,
              ownedItem: null,
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('Author view'), findsOneWidget);
    expect(find.text('J.R.R. Tolkien'), findsOneWidget);
  });

  testWidgets(
      'detail hero shows collection value totals when multiple copies exist', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind(CatalogMediaKind.book)!;
    final owned1 = testOwnedItem(
      id: 'owned-1',
      itemId: 'book-1',
      pricePaidCents: 1299,
      marketValueCents: 1899,
      currency: 'USD',
      updatedAt: DateTime.utc(2026, 5, 23),
    );
    final owned2 = testOwnedItem(
      id: 'owned-2',
      itemId: 'book-1',
      pricePaidCents: 999,
      marketValueCents: 2499,
      currency: 'USD',
      updatedAt: DateTime.utc(2026, 5, 22),
    );
    final source = ShelfEntry(
      itemId: 'book-1',
      catalogItem: testCatalogItem(
        id: 'book-1',
        kind: 'book',
        title: 'The Hobbit',
      ),
      ownedItem: owned1,
    );
    const node = LibraryTitleNodeRef(titleItemId: 'book-1');
    final dto = const BookWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final bookItem = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryDetailHero(
              type: type,
              item: bookItem,
              ownedItem: owned1,
              ownedCopies: [owned1, owned2],
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);

    expect(find.text('Total paid'), findsOneWidget);
    expect(find.text('USD 22.98'), findsOneWidget);
    expect(find.text('Total value'), findsOneWidget);
    expect(find.text('USD 43.98'), findsOneWidget);
  });
}
