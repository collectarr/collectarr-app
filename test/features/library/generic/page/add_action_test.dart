import 'package:collectarr_app/features/library/generic/page/shell_frame.dart';
import 'package:collectarr_app/features/library/workspace/chrome/actions.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [380.0, 1200.0]) {
    testWidgets('Add follows the native platform at width $width',
        (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var added = false;
      await tester.pumpWidget(MaterialApp(
          home: LibraryPageShellFrame(
        topBar: const SizedBox.shrink(),
        toolbar: LibraryToolbarPrimaryActions(
            addLabel: 'Add Comics',
            onAdd: () => added = true,
            onScanBarcode: () {},
            onRefreshMetadata: () {},
            addBackgroundColor: Colors.blue,
            addForegroundColor: Colors.white),
        content: const SizedBox.shrink(),
        bottomBar: const Text('Collections'),
        accent: Colors.orange,
        showAddButton: appPresentationPlatform.isNativeMobile,
        isScanningCover: false,
        onAdd: () => added = true,
        onEscape: () {},
      )));
      if (appPresentationPlatform.isNativeMobile) {
        expect(find.text('Add Comics'), findsNothing);
        final fab = tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton));
        expect(fab.shape, isA<CircleBorder>());
        expect(fab.foregroundColor, Colors.white);
        await tester.tap(find.byType(FloatingActionButton));
      } else {
        expect(find.byType(FloatingActionButton), findsNothing);
        await tester.tap(find.text('Add Comics'));
      }
      expect(added, isTrue);
    },
        variant: TargetPlatformVariant({
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.windows
        }));
  }
}
