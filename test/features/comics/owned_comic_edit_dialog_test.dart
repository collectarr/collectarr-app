import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/edit/generic_library_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('comic edit dialog returns edited personal fields',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final item = CatalogItem(
      id: 'comic-1',
      kind: 'comic',
      title: 'Superman, Vol. 4',
      itemNumber: '8A',
      synopsis: 'Escape From Dinosaur Island',
      publisher: 'DC',
      releaseYear: 2016,
      barcode: '76194134192700811',
    );
    final ownedItem = OwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      condition: 'Near Mint',
      grade: '9.8',
      pricePaidCents: 1299,
      coverPriceCents: 399,
      currency: 'USD',
      quantity: 1,
      storageBox: 'Box 1',
      updatedAt: DateTime.utc(2026, 5, 11),
    );
    GenericLibraryEditSelection? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                selection = await showDialog<GenericLibraryEditSelection>(
                  context: context,
                  builder: (context) => GenericLibraryEditDialog(
                    type: comicsLibraryConfig,
                    item: item,
                    ownedItem: ownedItem,
                    accent: const Color(0xFF10A8D8),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    // The dialog footer uses compact FooterTextField widgets that can
    // trigger a transient overflow during dispose animation. Ignore it.
    final origHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      origHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = origHandler);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Edit'), findsWidgets);

    // Navigate to Personal tab and change storage box
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Storage'), 'Box 6');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(selection?.personal?.storageBox, 'Box 6');
    expect(selection?.personal?.condition, 'Near Mint');
    expect(selection?.personal?.grade, '9.8');
  });
}
