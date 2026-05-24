import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/csv/import_export/import_export_wizard.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('import export wizard exposes collectarr and CLZ flows', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ImportExportWizardDialog(
              entries: [
                ShelfEntry(
                  itemId: 'comic-1',
                  catalogItem: CatalogItem(
                    id: 'comic-1',
                    kind: 'comic',
                    title: 'The Amazing Spider-Man',
                    itemNumber: '520',
                    publisher: 'Marvel Comics',
                    releaseDate: DateTime.utc(2005, 7, 1),
                  ),
                  ownedItem: OwnedItem(
                    id: 'owned-1',
                    itemId: 'comic-1',
                    quantity: 1,
                    updatedAt: DateTime.utc(2026, 5, 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CSV / CLZ import-export'), findsOneWidget);
    expect(find.text('Collectarr CSV'), findsOneWidget);
    expect(find.text('CLZ-friendly CSV'), findsOneWidget);
    expect(find.text('ComicInfo.xml'), findsOneWidget);
    expect(find.text('Copy Collectarr'), findsOneWidget);
    expect(find.text('Copy CLZ'), findsOneWidget);

    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(find.text('Collectarr CSV or CLZ-friendly CSV'), findsOneWidget);
    expect(find.text('Preview rows'), findsOneWidget);
    expect(find.text('Import 0'), findsOneWidget);
  });
}