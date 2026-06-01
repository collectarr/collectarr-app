import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/detail/library_detail_collection_sections.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('detail personal section shows value tracking fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryDetailPersonalSection(
            entry: LibraryWorkspaceEntry(
              id: 'movie-1',
              mediaType: 'movie',
              title: 'Blade Runner 2049',
              pricePaidCents: 1299,
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            ownedItem: OwnedItem(
              id: 'owned-1',
              itemId: 'movie-1',
              purchaseDate: DateTime.utc(2026, 5, 11),
              pricePaidCents: 1299,
              coverPriceCents: 1599,
              sellPriceCents: 1899,
              soldTo: 'Local shop',
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            ownedCopies: [
              OwnedItem(
                id: 'owned-1',
                itemId: 'movie-1',
                purchaseDate: DateTime.utc(2026, 5, 11),
                pricePaidCents: 1299,
                marketValueCents: 1599,
                coverPriceCents: 1599,
                sellPriceCents: 1899,
                soldTo: 'Local shop',
                currency: 'USD',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              OwnedItem(
                id: 'owned-2',
                itemId: 'movie-1',
                pricePaidCents: 999,
                marketValueCents: 2199,
                currency: 'USD',
                updatedAt: DateTime.utc(2026, 5, 21),
              ),
            ],
            trackingEntry: TrackingEntry(
              id: 'tracking-1',
              itemId: 'movie-1',
              progressCurrent: 5,
              progressTotal: 12,
              seasonNumber: 1,
              episodeNumber: 5,
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            accent: Colors.cyan,
          ),
        ),
      ),
    );

    expect(find.text('Cover price'), findsOneWidget);
    expect(find.text('USD 15.99'), findsOneWidget);
  expect(find.text('Current value'), findsOneWidget);
  expect(find.text('USD 15.99'), findsWidgets);
  expect(find.text('Total paid'), findsOneWidget);
  expect(find.text('USD 22.98'), findsOneWidget);
  expect(find.text('Total current value'), findsOneWidget);
  expect(find.text('USD 37.98'), findsOneWidget);
    expect(find.text('Sell price'), findsOneWidget);
    expect(find.text('USD 18.99'), findsOneWidget);
    expect(find.text('Profit / Loss'), findsOneWidget);
    expect(find.text('USD 6.00'), findsOneWidget);
    expect(find.text('Sold to'), findsOneWidget);
    expect(find.text('Local shop'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('5/12'), findsOneWidget);
    expect(find.text('Episode'), findsOneWidget);
    expect(find.text('S1 · Ep 5'), findsOneWidget);
  });
}