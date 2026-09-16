import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_factories.dart';

void main() {
  testWidgets('workspace card renders catalog and personal state',
      (tester) async {
    var tapped = false;
    final source = LibraryWorkspaceSource(
      itemId: 'comic-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Invincible Iron Man, Vol. 2',
        itemNumber: '13A',
        publisher: 'Marvel Comics',
        barcode: '759606083060141',
      ).asShelfCatalogItem),
      ownedSummary: testOwnedSummary(testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        grade: '9.4',
        condition: 'Near Mint',
        pricePaidCents: 399,
        currency: 'USD',
      )),
      wishlistItem: testWishlistItem(id: 'wish-1', itemId: 'comic-1'),
      locationPath: 'Box 6',
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
        child: MaterialApp(
          home: SizedBox(
            width: 420,
            height: 240,
            child: LibraryWorkspaceCard(
              item: comicItem,
              selected: true,
              onTap: () => tapped = true,
              dateFormatter: (value) =>
                  value.toIso8601String().split('T').first,
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
    expect(find.text('Near Mint'), findsNothing);
    expect(find.text('Wishlist'), findsOneWidget);
  });

  testWidgets('workspace card renders music release details', (tester) async {
    final source = LibraryWorkspaceSource(
      itemId: 'music-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'music-1',
        kind: 'music',
        title: 'Discovery',
        publisher: 'Virgin',
      ).asShelfCatalogItem),
      ownedSummary: testOwnedSummary(testOwnedItem(
        id: 'owned-m1',
        itemId: 'music-1',
        personalNotes: 'Japanese pressing',
      )),
    );
    const node = LibraryWorkRef(workId: 'music-1');
    final dto = const MusicWorkspaceProjector().project(
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
        child: MaterialApp(
          home: SizedBox(
            width: 420,
            height: 240,
            child: LibraryWorkspaceCard(
              item: musicItem,
              selected: false,
              onTap: () {},
              dateFormatter: (value) =>
                  value.toIso8601String().split('T').first,
              moneyFormatter: (cents, currency) => '$currency $cents',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Discovery'), findsWidgets);
    expect(find.text('Virgin'), findsOneWidget);
    expect(
      tester
          .widgetList<Text>(find.text('Discovery'))
          .any((text) => text.style?.color == Colors.white),
      isTrue,
    );
  });

  testWidgets('workspace card renders video runtime and game platforms',
      (tester) async {
    final sourceMovie = LibraryWorkspaceSource(
      itemId: 'movie-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Dune',
      ).asShelfCatalogItem),
      ownedSummary:
          testOwnedSummary(testOwnedItem(id: 'om1', itemId: 'movie-1')),
    );
    const nodeMovie = LibraryWorkRef(workId: 'movie-1');
    final dtoMovie = const MovieWorkspaceProjector().project(
      source: sourceMovie,
      entity: nodeMovie,
    );
    final movieItem = LibraryProjectionItem(
      source: sourceMovie,
      node: nodeMovie,
      dto: dtoMovie,
    );

    final sourceGame = LibraryWorkspaceSource(
      itemId: 'game-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'game-1',
        kind: 'game',
        title: 'Mario Kart 8 Deluxe',
      ).asShelfCatalogItem),
      ownedSummary:
          testOwnedSummary(testOwnedItem(id: 'og1', itemId: 'game-1')),
    );
    const nodeGame = LibraryWorkRef(workId: 'game-1');
    final dtoGame = const GameWorkspaceProjector().project(
      source: sourceGame,
      entity: nodeGame,
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
