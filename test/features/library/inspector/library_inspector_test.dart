import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inspector section renders title and children', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LibraryInspectorSection(
            title: 'Personal',
            children: [Text('Storage box')],
          ),
        ),
      ),
    );

    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Storage box'), findsOneWidget);
  });

  testWidgets('inspector fact grid renders fact labels and values',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 500,
            child: LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData('Grade', '9.8'),
                LibraryInspectorFactData('Condition', 'Near Mint'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grade'), findsOneWidget);
    expect(find.text('9.8'), findsOneWidget);
    expect(find.text('Condition'), findsOneWidget);
    expect(find.text('Near Mint'), findsOneWidget);
  });

  testWidgets('personal section shows cover price for non-comic items',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InspectorPersonalSection(
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
              coverPriceCents: 1599,
              currency: 'USD',
              updatedAt: DateTime.utc(2026, 5, 22),
            ),
            accent: Colors.orange,
            kind: 'movie',
          ),
        ),
      ),
    );

    expect(find.text('Cover price'), findsOneWidget);
    expect(find.text('USD 15.99'), findsOneWidget);
  });
}
