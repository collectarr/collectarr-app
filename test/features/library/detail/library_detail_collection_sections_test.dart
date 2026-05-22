import 'package:collectarr_app/core/models/owned_item.dart';
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
            accent: Colors.cyan,
          ),
        ),
      ),
    );

    expect(find.text('Cover price'), findsOneWidget);
    expect(find.text('USD 15.99'), findsOneWidget);
    expect(find.text('Sell price'), findsOneWidget);
    expect(find.text('USD 18.99'), findsOneWidget);
    expect(find.text('Profit / Loss'), findsOneWidget);
    expect(find.text('USD 6.00'), findsOneWidget);
    expect(find.text('Sold to'), findsOneWidget);
    expect(find.text('Local shop'), findsOneWidget);
  });
}