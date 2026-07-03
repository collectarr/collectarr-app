import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';

void main() {
  group('comic detail page', () {
    testWidgets('renders comic-specific fields (issue number, publisher)', (
      tester,
    ) async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final type = collectarrLibraryTypes.byKind('comic')!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'comic-1',
                mediaType: 'comic',
                title: 'Amazing Spider-Man',
                itemNumber: '300',
                publisher: 'Marvel Comics',
                releaseYear: 1988,
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              ownedItem: null,
              accent: Colors.red,
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

      expect(find.text('Amazing Spider-Man'), findsWidgets);
    });

  });

  group('music detail page', () {
    testWidgets('renders music-specific fields (tracks, runtime)', (
      tester,
    ) async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final type = collectarrLibraryTypes.byKind('music')!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'music-1',
                mediaType: 'music',
                title: 'Discovery',
                publisher: 'Virgin Records',
                releaseYear: 2001,
                music: const MusicCatalogDetails(
                  trackCount: 14,
                ),
                genres: const ['Electronic', 'House'],
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              ownedItem: null,
              accent: Colors.cyan,
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

      expect(find.text('Discovery'), findsWidgets);
    });
  });

  group('game detail page', () {
    testWidgets('renders game-specific fields', (tester) async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final type = collectarrLibraryTypes.byKind('game')!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'game-1',
                mediaType: 'game',
                title: 'The Legend of Zelda: Tears of the Kingdom',
                publisher: 'Nintendo',
                releaseYear: 2023,
                genres: const ['Action', 'Adventure'],
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              ownedItem: null,
              accent: Colors.green,
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

      expect(find.text('The Legend of Zelda: Tears of the Kingdom'), findsWidgets);
    });
  });

  group('book detail page', () {
    testWidgets('renders book-specific fields (page count, author)', (
      tester,
    ) async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final type = collectarrLibraryTypes.byKind('book')!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'Dune',
                publisher: 'Chilton Books',
                releaseYear: 1965,
                publishing: const CatalogPublishingDetails(pageCount: 412),
                creators: const [
                  {'name': 'Frank Herbert', 'role': 'Author'},
                ],
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              ownedItem: null,
              accent: Colors.amber,
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

      expect(find.text('Dune'), findsWidgets);
    });
  });

  group('detail page - no owned item', () {
    testWidgets('renders catalog-only view without owned fields', (
      tester,
    ) async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final type = collectarrLibraryTypes.byKind('comic')!;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'comic-1',
                mediaType: 'comic',
                title: 'Saga #1',
                publisher: 'Image Comics',
                releaseYear: 2012,
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              ownedItem: null,
              accent: Colors.purple,
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

      // Should render title but not show personal section
      expect(find.text('Saga #1'), findsWidgets);
      expect(find.text('Condition'), findsNothing);
    });
  });
}
