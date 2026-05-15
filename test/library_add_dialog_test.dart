import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/planned_library_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('generic add dialog exposes scanned barcode in manual flow',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: gamesLibraryConfig,
              initialBarcode: '759606083060',
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Add Games'), findsOneWidget);
    expect(
      find.text(
        'Core search uses the configured metadata server. If it is offline, use the manual panel; local items still sync normally.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Barcode 759606083060 is prefilled for games. Search Core or add it manually with the same code.',
      ),
      findsOneWidget,
    );
    expect(find.text('Barcode / UPC / ISBN'), findsWidgets);
    expect(
      find.widgetWithText(TextField, 'Barcode / UPC / ISBN'),
      findsWidgets,
    );
  });
}
