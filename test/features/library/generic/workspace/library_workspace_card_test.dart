import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_factories.dart';

void main() {
  testWidgets('workspace card renders catalog and personal state',
      (tester) async {
    var tapped = false;
    final source = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Invincible Iron Man, Vol. 2',
        itemNumber: '13A',
        publisher: 'Marvel Comics',
        barcode: '759606083060141',
      ),
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        grade: '9.4',
        condition: 'Near Mint',
        pricePaidCents: 399,
        currency: 'USD',
      ),
      wishlistItem: testWishlistItem(id: 'wish-1', itemId: 'comic-1'),
      locationPath: 'Box 6',
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
        child: MaterialApp(
          home: SizedBox(
            width: 420,
            height: 240,
            child: LibraryWorkspaceCard(
              item: comicItem,
              selected: true,
              onTap: () => tapped = true,
              dateFormatter: (value) => value.toIso8601String().split('T').first,
              moneyFormatter: (cents, currency) => '$currency $cents',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Invincible Iron Man, Vol. 2'));

    expect(tapped, isTrue);
    expect(find.text('#13A'), findsWidgets);
    expect(find.textContaining('Marvel Comics'), findsOneWidget);
    expect(find.text('Near Mint'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
  });

  testWidgets('workspace card renders music release details', (tester) async {
    final source = ShelfEntry(
      itemId: 'music-1',
      catalogItem: testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Discovery',
        publisher: 'Virgin',
      ),
      ownedItem: testOwnedItem(
        id: 'owned-m1',
        itemId: 'music-1',
        personalNotes: 'Japanese pressing',
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
        child: MaterialApp(
          home: SizedBox(
            width: 420,
            height: 240,
            child: LibraryWorkspaceCard(
              item: musicItem,
              selected: false,
              onTap: () {},
              dateFormatter: (value) => value.toIso8601String().split('T').first,
              moneyFormatter: (cents, currency) => '$currency $cents',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Discovery'), findsWidgets);
    expect(find.text('Virgin'), findsOneWidget);
  });

  testWidgets('workspace card renders video runtime and game platforms',
      (tester) async {
    final sourceMovie = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Dune',
      ),
      ownedItem: testOwnedItem(id: 'om1', itemId: 'movie-1'),
    );
    const nodeMovie = LibraryTitleNodeRef(titleItemId: 'movie-1');
    final dtoMovie = const MovieWorkspaceProjector().projectTitle(
      source: sourceMovie,
      node: nodeMovie,
    );
    final movieItem = LibraryProjectionItem(
      source: sourceMovie,
      node: nodeMovie,
      dto: dtoMovie,
    );

    final sourceGame = ShelfEntry(
      itemId: 'game-1',
      catalogItem: testCatalogItem(
        id: 'game-1',
        kind: 'game',
        title: 'Mario Kart 8 Deluxe',
      ),
      ownedItem: testOwnedItem(id: 'og1', itemId: 'game-1'),
    );
    const nodeGame = LibraryTitleNodeRef(titleItemId: 'game-1');
    final dtoGame = const GameWorkspaceProjector().projectTitle(
      source: sourceGame,
      node: nodeGame,
    );
    final gameItem = LibraryProjectionItem(
      source: sourceGame,
      node: nodeGame,
      dto: dtoGame,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: 420,
                  height: 240,
                  child: LibraryWorkspaceCard(
                    item: movieItem,
                    selected: false,
                    onTap: () {},
                    dateFormatter: (value) =>
                        value.toIso8601String().split('T').first,
                    moneyFormatter: (cents, currency) => '$currency $cents',
                  ),
                ),
                SizedBox(
                  width: 420,
                  height: 240,
                  child: LibraryWorkspaceCard(
                    item: gameItem,
                    selected: false,
                    onTap: () {},
                    dateFormatter: (value) =>
                        value.toIso8601String().split('T').first,
                    moneyFormatter: (cents, currency) => '$currency $cents',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dune'), findsWidgets);
    expect(find.text('Mario Kart 8 Deluxe'), findsWidgets);
  });
}
