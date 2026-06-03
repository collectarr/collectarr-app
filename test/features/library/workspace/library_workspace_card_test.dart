import 'package:collectarr_app/features/library/workspace/tiles/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workspace card renders catalog and personal state',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 420,
          height: 170,
          child: LibraryWorkspaceCard(
            entry: LibraryWorkspaceEntry(
              id: 'comic-1',
              mediaType: 'comic',
              title: 'Invincible Iron Man, Vol. 2',
              itemNumber: '13A',
              publisher: 'Marvel Comics',
              releaseDate: DateTime.utc(2016, 9, 7),
              barcode: '759606083060141',
              grade: '9.4',
              condition: 'Near Mint',
              rawOrSlabbed: 'Slabbed',
              gradingCompany: 'CGC',
              keyComic: true,
              keyReason: 'First appearance',
              pricePaidCents: 399,
              currency: 'USD',
              locationPath: 'Box 6',
              isOwned: true,
              isWishlisted: true,
              updatedAt: DateTime.utc(2026),
            ),
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
    expect(find.text('9.4'), findsWidgets);
    expect(find.text('Near Mint'), findsOneWidget);
    expect(find.text('First appearance'), findsOneWidget);
    expect(find.text('Slabbed - CGC'), findsOneWidget);
    expect(find.text('Box 6'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
  });

  testWidgets('workspace card renders music release details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 420,
          height: 170,
          child: LibraryWorkspaceCard(
            entry: LibraryWorkspaceEntry(
              id: 'music-1',
              mediaType: 'music',
              title: 'Discovery',
              publisher: 'Virgin',
              isOwned: true,
              notes: 'Japanese pressing',
              referenceEditionId: 'edition-1',
              referenceVariantId: 'variant-1',
              editions: const [
                CatalogEdition(
                  id: 'edition-1',
                  title: 'Deluxe Edition',
                  variants: [
                    CatalogVariant(
                      id: 'variant-1',
                      name: 'Japan CD',
                    ),
                  ],
                ),
              ],
              music: const MusicCatalogDetails(
                trackCount: 14,
                releaseStatus: 'Official',
              ),
              updatedAt: DateTime.utc(2026),
            ),
            selected: false,
            onTap: () {},
            dateFormatter: (value) => value.toIso8601String().split('T').first,
            moneyFormatter: (cents, currency) => '$currency $cents',
          ),
        ),
      ),
    );

    expect(find.text('14 tracks'), findsOneWidget);
    expect(find.text('Official'), findsOneWidget);
    expect(find.text('Japanese pressing'), findsOneWidget);
    expect(
      find.text('Album  ->  Edition: Deluxe Edition  ->  Physical: Japan CD'),
      findsOneWidget,
    );
  });

  testWidgets('workspace card renders video runtime and game platforms',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            SizedBox(
              width: 420,
              height: 170,
              child: LibraryWorkspaceCard(
                entry: LibraryWorkspaceEntry(
                  id: 'movie-1',
                  mediaType: 'movie',
                  title: 'Dune',
                  isOwned: true,
                  video: const VideoCatalogDetails(runtimeMinutes: 155),
                  updatedAt: DateTime.utc(2026),
                ),
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
                entry: LibraryWorkspaceEntry(
                  id: 'game-1',
                  mediaType: 'game',
                  title: 'Mario Kart 8 Deluxe',
                  isOwned: true,
                  game: const GameCatalogDetails(platforms: ['Switch', 'Wii U']),
                  updatedAt: DateTime.utc(2026),
                ),
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
