import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('manual-only barcode sheet returns normalized input',
      (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const BarcodeScanSheet(
                    cameraSupported: false,
                    platform: TargetPlatform.windows,
                  ),
                );
              },
              child: const Text('Open scanner'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open scanner'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Camera scanning is not available on this platform. Enter the barcode manually.',
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextField),
      ' 7596-060 83060 ',
    );
    await tester.tap(find.text('Lookup barcode'));
    await tester.pumpAndSettle();

    expect(result, '759606083060');
  });

  testWidgets('barcode sheet can describe the active media add flow',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BarcodeScanSheet(
            cameraSupported: false,
            platform: TargetPlatform.windows,
            title: 'Scan game barcode',
            description:
                'Scan or enter a barcode. Collectarr will open Add Games with this code prefilled.',
            manualLabel: 'Game barcode / UPC / ISBN',
            submitLabel: 'Continue to Add Games',
            leadingIcon: Icons.sports_esports,
          ),
        ),
      ),
    );

    expect(find.text('Scan game barcode'), findsOneWidget);
    expect(
      find.text(
        'Scan or enter a barcode. Collectarr will open Add Games with this code prefilled.',
      ),
      findsOneWidget,
    );
    expect(find.text('Game barcode / UPC / ISBN'), findsOneWidget);
    expect(find.text('Continue to Add Games'), findsOneWidget);
  });
}
