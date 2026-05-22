import 'package:collectarr_app/features/library/workspace/library_workspace_card.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
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
              storageBox: 'Box 6',
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
    expect(find.text('9.4'), findsOneWidget);
    expect(find.text('Near Mint'), findsOneWidget);
    expect(find.text('First appearance'), findsOneWidget);
    expect(find.text('Slabbed - CGC'), findsOneWidget);
    expect(find.text('Box 6'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
  });
}
