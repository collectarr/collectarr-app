import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('detail hero keeps a back cover affordance when the back image is missing', (
    tester,
  ) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: 'front-only-1',
            ownedItemId: 'owned-1',
            imageType: const Value('front_cover'),
            imageData: base64Encode(const [0, 1, 2, 3]),
            createdAt: DateTime.utc(2026, 5, 23),
          ),
        );

    final type = collectarrLibraryTypes.byKind('book')!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryDetailHero(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Fellowship of the Ring',
                ownedItemId: 'owned-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: OwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Back cover'), findsOneWidget);
  });

  testWidgets('detail hero exposes back cover toggle when local back cover exists', (
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

    final type = collectarrLibraryTypes.byKind('book')!;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: LibraryDetailHero(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Two Towers',
                itemNumber: '2',
                ownedItemId: 'owned-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: OwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'View back'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'View back'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'View front'), findsOneWidget);
  });

  testWidgets('detail hero shows a book author spotlight when creators exist', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind('book')!;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryDetailHero(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Return of the King',
                creators: [
                  {
                    'name': 'J.R.R. Tolkien',
                    'role': 'Author',
                  },
                ],
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: null,
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Author view'), findsOneWidget);
    expect(find.text('J.R.R. Tolkien'), findsOneWidget);
  });

  testWidgets('detail hero shows the active ownership reference label', (
    tester,
  ) async {
    final type = collectarrLibraryTypes.byKind('book')!;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryDetailHero(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'The Silmarillion',
                primaryReferenceLabel: 'Owned as bundle',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              ownedItem: OwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                anchorType: 'bundle_release',
                bundleReleaseId: 'bundle-book-1',
                updatedAt: DateTime.utc(2026, 5, 23),
              ),
              accent: Colors.orange,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Owned as bundle'), findsOneWidget);
  });
}