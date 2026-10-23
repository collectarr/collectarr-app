import 'dart:ui' as ui;

import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/ui/app_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/accessibility/semantics_recording_binding.dart';

void main() {
  final binding =
      TestWidgetsFlutterBinding.instance as SemanticsRecordingTestBinding;
  for (final libraryStyle in [true, false]) {
    testWidgets(
        '${libraryStyle ? 'library' : 'settings'} slider sends no orphan accessibility nodes through route transitions',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final semantics = tester.ensureSemantics();
      var value = 20.0;
      try {
        await tester.pumpWidget(MaterialApp(
            home: Builder(
                builder: (context) => Scaffold(
                      body: TextButton(
                          onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute<void>(
                                  builder: (_) => StatefulBuilder(
                                      builder: (context, setState) => Scaffold(
                                            appBar: AppBar(
                                                title: const Text('Sliders')),
                                            body: Column(children: [
                                              ListTile(
                                                  title: const Text('Value'),
                                                  subtitle: SizedBox(
                                                      width: 180,
                                                      child: libraryStyle
                                                          ? LibraryRangeSlider(
                                                              value: value,
                                                              min: 0,
                                                              max: 100,
                                                              onChanged: (next) =>
                                                                  setState(() =>
                                                                      value =
                                                                          next))
                                                          : AppSlider(
                                                              value: value,
                                                              min: 0,
                                                              max: 100,
                                                              divisions: 20,
                                                              label: '$value',
                                                              onChanged: (next) =>
                                                                  setState(() =>
                                                                      value =
                                                                          next)))),
                                              TextButton(
                                                  onPressed: () => showDialog<
                                                          void>(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                              title: const Text(
                                                                  'Overlay'),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child: const Text(
                                                                        'Close'))
                                                              ])),
                                                  child: const Text(
                                                      'Open dialog')),
                                            ]),
                                          )))),
                          child: const Text('Open library')),
                    ))));
        await tester.pumpAndSettle();
        binding.orphans.clear();
        await tester.tap(find.text('Open library'));
        await tester.pumpAndSettle();
        final root = tester.getSemantics(find.byType(Slider));
        SemanticsNode? sliderNode;
        void findSlider(SemanticsNode node) {
          if (node.getSemanticsData().flagsCollection.isSlider) {
            sliderNode = node;
          }
          node.visitChildren((child) {
            findSlider(child);
            return true;
          });
        }

        findSlider(root);
        expect(sliderNode, isNotNull, reason: root.toStringDeep());
        final node = sliderNode!;
        expect(node.getSemanticsData().hasAction(ui.SemanticsAction.increase),
            isTrue);
        expect(node.getSemanticsData().hasAction(ui.SemanticsAction.decrease),
            isTrue);
        node.owner!.performAction(node.id, ui.SemanticsAction.increase);
        await tester.pumpAndSettle();
        expect(value, greaterThan(20));
        final rect = tester.getRect(find.byType(Slider));
        await tester.tapAt(rect.center);
        await tester.pumpAndSettle();
        final beforeKey = value;
        final sliderFocus = tester
            .widget<FocusableActionDetector>(find.descendant(
                of: find.byType(Slider),
                matching: find.byType(FocusableActionDetector)))
            .focusNode!;
        for (var i = 0; i < 8 && !sliderFocus.hasFocus; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
        }
        expect(sliderFocus.hasFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(value, greaterThan(beforeKey));
        if (libraryStyle) {
          expect(tester.getSize(find.byType(LibraryRangeSlider)),
              tester.getSize(find.byType(Slider)));
        }
        await tester.tap(find.text('Open dialog'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Open library'), findsOneWidget);
        expect(binding.orphans, isEmpty,
            reason:
                'Windows rejects nodes unreachable from the semantics root.');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      } finally {
        semantics.dispose();
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
