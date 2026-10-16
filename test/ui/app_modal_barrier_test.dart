import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final mode in ['dialog', 'transparent dialog', 'sheet']) {
    testWidgets('$mode consumes outside taps without dismissing or sounding',
        (tester) async {
      final sounds = <MethodCall>[];
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'SystemSound.play') sounds.add(call);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));
      await tester.pumpWidget(MaterialApp(
          home: Builder(
              builder: (context) => TextButton(
                  onPressed: () {
                    Widget panel(BuildContext context) => mode == 'sheet'
                        ? SizedBox(
                            height: 150,
                            child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close panel')))
                        : AccentAlertDialog(
                            title: const Text('Panel'),
                            content: const Text('Content'),
                            actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close panel'))
                              ]);
                    if (mode == 'sheet') {
                      showAppBottomSheet<void>(
                          context: context, builder: panel);
                    } else {
                      showAppDialog<void>(
                          context: context,
                          barrierColor: mode == 'transparent dialog'
                              ? Colors.transparent
                              : Colors.black54,
                          builder: panel);
                    }
                  },
                  child: const Text('Open')))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      if (mode != 'sheet') {
        final surface = find
            .descendant(
                of: find.byType(Dialog), matching: find.byType(Material))
            .first;
        expect(tester.getTopLeft(surface).dy, 30);
      }
      sounds.clear();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Close panel'), findsOneWidget);
      expect(sounds, isEmpty);
      await tester.tap(find.text('Close panel'));
      await tester.pumpAndSettle();
      expect(find.text('Close panel'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
