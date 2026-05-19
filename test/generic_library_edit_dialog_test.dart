import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/edit/generic_library_edit_dialog.dart';
import 'package:collectarr_app/features/library/physical_media_formats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'generic edit dialog returns media-aware catalog and owned fields',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final type = collectarrLibraryTypes.byKind('movie')!;
    final item = CatalogItem(
      id: 'movie-1',
      kind: 'movie',
      title: 'Blade Runner',
      itemNumber: '1',
      publisher: 'Warner Bros.',
      releaseYear: 1982,
      variant: 'DVD',
      barcode: '883929087129',
    );
    final ownedItem = OwnedItem(
      id: 'owned-1',
      itemId: 'movie-1',
      condition: 'Good',
      pricePaidCents: 999,
      currency: 'USD',
      quantity: 1,
      storageBox: 'Shelf A',
      updatedAt: DateTime.utc(2026, 5, 15),
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
                    type: type,
                    item: item,
                    ownedItem: ownedItem,
                    accent: Colors.red,
                    physicalFormats: videoPhysicalMediaFormats,
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Edit movie'), findsOneWidget);
    expect(find.text('Format / Edition'), findsOneWidget);
    expect(find.text('UPC / Barcode'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Title'),
      'Blade Runner: Final Cut',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4K UHD'));
    await tester.pumpAndSettle();

    // Navigate to Value tab to set price
    await tester.tap(find.text('Value'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Price paid'), '12.50');

    // Navigate to Personal tab to set storage
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Storage'), 'Shelf B');

    // The dialog footer can trigger a transient RenderFlex overflow during
    // the dismiss animation in compact test viewports. Suppress it.
    final origHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      origHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = origHandler);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(selection?.catalogItem.title, 'Blade Runner: Final Cut');
    expect(selection?.catalogItem.variant, '4K UHD');
    expect(selection?.catalogItem.physicalFormat, '4k-uhd');
    expect(selection?.catalogItem.physicalFormatLabel, '4K UHD');
    expect(selection?.catalogItem.barcode, '883929087129');
    expect(selection?.personal?.storageBox, 'Shelf B');
    expect(selection?.personal?.pricePaidCents, 1250);
    expect(selection?.personal?.quantity, 1);
  });
}
