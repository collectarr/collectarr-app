import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';
import '../../helpers/test_data_factories.dart';

void main() {
  group('comic detail page', () {
    testWidgets('renders comic-specific fields (issue number, publisher)', (
      tester,
    ) async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final type = collectarrLibraryTypes.byKind(CatalogMediaKind.comic)!;
      final source = ShelfEntry(
        itemId: 'comic-1',
        catalogItem: testCatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Amazing Spider-Man',
          publisher: 'Marvel Comics',
        ),
      );
      const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
      final dto = const ComicWorkspaceProjector().projectTitle(
        source: source,
        node: node,
      );
      final comicItem = LibraryProjectionItem(
        source: source,
        node: node,
        dto: dto,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              item: comicItem,
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
      final type = collectarrLibraryTypes.byKind(CatalogMediaKind.music)!;
      final source = ShelfEntry(
        itemId: 'music-1',
        catalogItem: testCatalogItem(
          id: 'music-1',
          kind: 'music',
          title: 'Discovery',
          publisher: 'Virgin Records',
          genres: ['Electronic', 'House'],
        ),
      );
      const node = LibraryTitleNodeRef(titleItemId: 'music-1');
      final dto = const MusicWorkspaceProjector().projectTitle(
        source: source,
        node: node,
      );
      final musicItem = LibraryProjectionItem(
        source: source,
        node: node,
        dto: dto,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              item: musicItem,
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
      final type = collectarrLibraryTypes.byKind(CatalogMediaKind.game)!;
      final source = ShelfEntry(
        itemId: 'game-1',
        catalogItem: testCatalogItem(
          id: 'game-1',
          kind: 'game',
          title: 'The Legend of Zelda: Tears of the Kingdom',
          publisher: 'Nintendo',
          genres: ['Action', 'Adventure'],
        ),
      );
      const node = LibraryTitleNodeRef(titleItemId: 'game-1');
      final dto = const GameWorkspaceProjector().projectTitle(
        source: source,
        node: node,
      );
      final gameItem = LibraryProjectionItem(
        source: source,
        node: node,
        dto: dto,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              item: gameItem,
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
      final type = collectarrLibraryTypes.byKind(CatalogMediaKind.book)!;
      final source = ShelfEntry(
        itemId: 'book-1',
        catalogItem: testCatalogItem(
          id: 'book-1',
          kind: 'book',
          title: 'Dune',
          publisher: 'Chilton Books',
          creators: [
            {'name': 'Frank Herbert', 'role': 'Author'},
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
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              item: bookItem,
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
      final type = collectarrLibraryTypes.byKind(CatalogMediaKind.comic)!;
      final source = ShelfEntry(
        itemId: 'comic-1',
        catalogItem: testCatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Saga #1',
          publisher: 'Image Comics',
        ),
      );
      const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
      final dto = const ComicWorkspaceProjector().projectTitle(
        source: source,
        node: node,
      );
      final comicItem = LibraryProjectionItem(
        source: source,
        node: node,
        dto: dto,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [localDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LibraryDetailPage(
              type: type,
              item: comicItem,
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

      expect(find.text('Saga #1'), findsWidgets);
    });
  });
}
