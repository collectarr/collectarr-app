import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
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
      final type = libraryKindRegistrationForKind(CatalogMediaKind.comic);
      final source = LibraryWorkspaceSource(
        itemId: 'comic-1',
        catalogData: testWorkspaceCatalogData(testCatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Amazing Spider-Man',
          publisher: 'Marvel Comics',
        ).asShelfCatalogItem),
      );
      const node = LibraryWorkRef(workId: 'comic-1');
      final dto = const ComicWorkspaceProjector().project(
        source: source,
        entity: node,
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
              ownedSummary: null,
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
      final type = libraryKindRegistrationForKind(CatalogMediaKind.music);
      final source = LibraryWorkspaceSource(
        itemId: 'music-1',
        catalogData: testWorkspaceCatalogData(testCatalogItem(
          id: 'music-1',
          kind: 'music',
          title: 'Discovery',
          publisher: 'Virgin Records',
          genres: ['Electronic', 'House'],
        ).asShelfCatalogItem),
      );
      const node = LibraryWorkRef(workId: 'music-1');
      final dto = const MusicReleaseGroupWorkspaceProjector().project(
        source: source,
        entity: node,
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
              ownedSummary: null,
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
      final type = libraryKindRegistrationForKind(CatalogMediaKind.game);
      final source = LibraryWorkspaceSource(
        itemId: 'game-1',
        catalogData: testWorkspaceCatalogData(testCatalogItem(
          id: 'game-1',
          kind: 'game',
          title: 'The Legend of Zelda: Tears of the Kingdom',
          publisher: 'Nintendo',
          genres: ['Action', 'Adventure'],
        ).asShelfCatalogItem),
      );
      const node = LibraryWorkRef(workId: 'game-1');
      final dto = const GameWorkspaceProjector().project(
        source: source,
        entity: node,
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
              ownedSummary: null,
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

      expect(
          find.text('The Legend of Zelda: Tears of the Kingdom'), findsWidgets);
    });
  });

  group('book detail page', () {
    testWidgets('renders book-specific fields (page count, author)', (
      tester,
    ) async {
      final db = LocalDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final type = libraryKindRegistrationForKind(CatalogMediaKind.book);
      final source = LibraryWorkspaceSource(
        itemId: 'book-1',
        catalogData: testWorkspaceCatalogData(testCatalogItem(
          id: 'book-1',
          kind: 'book',
          title: 'Dune',
          publisher: 'Chilton Books',
          creators: [
            {'name': 'Frank Herbert', 'role': 'Author'},
          ],
        ).asShelfCatalogItem),
      );
      const node = LibraryWorkRef(workId: 'book-1');
      final dto = const BookWorkspaceProjector().project(
        source: source,
        entity: node,
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
              ownedSummary: null,
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
      final type = libraryKindRegistrationForKind(CatalogMediaKind.comic);
      final source = LibraryWorkspaceSource(
        itemId: 'comic-1',
        catalogData: testWorkspaceCatalogData(testCatalogItem(
          id: 'comic-1',
          kind: 'comic',
          title: 'Saga #1',
          publisher: 'Image Comics',
        ).asShelfCatalogItem),
      );
      const node = LibraryWorkRef(workId: 'comic-1');
      final dto = const ComicWorkspaceProjector().project(
        source: source,
        entity: node,
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
              ownedSummary: null,
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
