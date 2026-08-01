import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/presentation.dart';
import 'package:collectarr_app/features/library/kinds/game/presentation.dart';
import 'package:collectarr_app/features/library/kinds/music/presentation.dart';
import 'package:collectarr_app/features/library/shared/video_library_media_presentation_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_factories.dart';

void main() {
  testWidgets('workspace card renders catalog and personal state',
      (tester) async {
    var tapped = false;
    final comicItem = const ComicWorkspaceProjector().project(
      source: ShelfEntry(
        catalogItem: CatalogItemDto(
          id: 'comic-1',
          kind: 'comic',
          title: 'Invincible Iron Man, Vol. 2',
          issueNumber: '13A',
          publisher: 'Marvel Comics',
          barcode: '759606083060141',
          comic: const CatalogComicDetails(
            rawOrSlabbed: 'Slabbed',
            gradingCompany: 'CGC',
            keyComic: true,
            keyReason: 'First appearance',
            coverDate: DateTime.utc(2016, 9, 7),
          ),
        ),
        ownedItem: testOwnedItem(
          id: 'owned-1',
          itemId: 'comic-1',
          grade: '9.4',
          condition: 'Near Mint',
          pricePaidCents: 399,
          currency: 'USD',
          rawOrSlabbed: 'Slabbed',
          gradingCompany: 'CGC',
          keyComic: true,
          keyReason: 'First appearance',
        ),
        wishlistItem: testWishlistItem(id: 'wish-1', itemId: 'comic-1'),
        locationPath: 'Box 6',
      ),
      node: const LibraryTitleNodeRef('comic-1'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 420,
          height: 170,
          child: LibraryWorkspaceCard(
            item: comicItem,
            selected: true,
            onTap: () => tapped = true,
            dateFormatter: (value) => value.toIso8601String().split('T').first,
            moneyFormatter: (cents, currency) => '$currency $cents',
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
    final musicItem = const MusicWorkspaceProjector().project(
      source: ShelfEntry(
        catalogItem: const CatalogItemDto(
          id: 'music-1',
          kind: 'music',
          title: 'Discovery',
          publisher: 'Virgin',
          editions: [
            CatalogEdition(
              id: 'edition-1',
              name: 'Deluxe Edition',
              variants: [
                CatalogVariant(
                  id: 'variant-1',
                  name: 'Japan CD',
                ),
              ],
            ),
          ],
          music: CatalogMusicDetails(
            trackCount: 14,
            releaseStatus: 'Official',
          ),
        ),
        ownedItem: testOwnedItem(
          id: 'owned-m1',
          itemId: 'music-1',
          editionId: 'edition-1',
          variantId: 'variant-1',
          personalNotes: 'Japanese pressing',
        ),
      ),
      node: const LibraryReleaseNodeRef('music-1', editionId: 'edition-1', variantId: 'variant-1'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 420,
          height: 170,
          child: LibraryWorkspaceCard(
            item: musicItem,
            selected: false,
            onTap: () {},
            dateFormatter: (value) => value.toIso8601String().split('T').first,
            moneyFormatter: (cents, currency) => '$currency $cents',
          ),
        ),
      ),
    );

    expect(find.text('Discovery'), findsWidgets);
    expect(find.text('Virgin'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });

  testWidgets('workspace card renders video runtime and game platforms',
      (tester) async {
    final movieItem = VideoLibraryWorkspaceProjector(kind: 'movie').project(
      source: ShelfEntry(
        catalogItem: const CatalogItemDto(
          id: 'movie-1',
          kind: 'movie',
          title: 'Dune',
          video: CatalogVideoDetails(runtimeMinutes: 155),
        ),
        ownedItem: testOwnedItem(id: 'om1', itemId: 'movie-1'),
      ),
      node: const LibraryTitleNodeRef('movie-1'),
    );

    final gameItem = const GameWorkspaceProjector().project(
      source: ShelfEntry(
        catalogItem: const CatalogItemDto(
          id: 'game-1',
          kind: 'game',
          title: 'Mario Kart 8 Deluxe',
          rawPlatforms: ['Switch', 'Wii U'],
        ),
        ownedItem: testOwnedItem(id: 'og1', itemId: 'game-1'),
      ),
      node: const LibraryTitleNodeRef('game-1'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            SizedBox(
              width: 420,
              height: 170,
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
              height: 170,
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
    );

    expect(find.text('155 min'), findsOneWidget);
    expect(find.text('Switch +1'), findsOneWidget);
  });
}
