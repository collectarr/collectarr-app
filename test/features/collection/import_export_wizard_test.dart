import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/csv/import_export/import_export_wizard.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_constants.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  testWidgets('import export wizard exposes collectarr and CLZ flows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
                  ownedItem: testOwnedItem(
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
    await pumpUntilSettled(tester);

    expect(find.text('Import or export collection'), findsOneWidget);
    expect(find.text('Collectarr CSV'), findsOneWidget);
    expect(find.text('CLZ-friendly CSV'), findsOneWidget);
    expect(find.text('ComicInfo.xml'), findsOneWidget);
    expect(find.text('Copy Collectarr CSV'), findsOneWidget);
    expect(find.text('Copy CLZ-friendly CSV'), findsOneWidget);

    await tester.tap(find.text('Import collection'));
    await pumpUntilSettled(tester);

    expect(find.text('Paste Collectarr CSV or CLZ-friendly CSV'), findsOneWidget);
    expect(find.text('Preview import'), findsOneWidget);
    expect(find.text('Import 0 rows'), findsOneWidget);
  });
}
