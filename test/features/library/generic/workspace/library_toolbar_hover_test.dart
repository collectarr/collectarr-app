import 'dart:ui';

import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final compact in [true, false]) {
      testWidgets(
          'inspector Layout hover and selection ($brightness, $compact)',
          (tester) async {
        var layout = LibraryDetailsLayout.right;
        await tester.pumpWidget(MaterialApp(
          theme: buildAppShellTheme(
              palette: brightness == Brightness.light
                  ? kLightAppThemePalette
                  : kDefaultAppThemePalette),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: StatefulBuilder(builder: (context, setState) {
                return LibraryDetailsLayoutDropdown(
                  detailsLayout: layout,
                  onChanged: (value) => setState(() => layout = value),
                  inspectorStyle: true,
                  iconOnly: compact,
                );
              }),
            ),
          ),
        ));
        final trigger =
            find.byKey(const Key('library-details-layout-dropdown'));
        expect(tester.getSize(trigger).height, 30);
        if (compact) expect(tester.getSize(trigger).width, 46);
        expect(find.byIcon(AppIcons.chevronDown), findsOneWidget);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(790, 590));
        await mouse.moveTo(tester.getCenter(trigger));
        await tester.pumpAndSettle();
        final surface = find.descendant(
            of: trigger, matching: find.byType(AnimatedContainer));
        expect(
            (tester.widget<AnimatedContainer>(surface).decoration
                    as BoxDecoration)
                .color,
            libraryToolbarControlHover(tester.element(trigger)));
        expect(RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
            SystemMouseCursors.click);
        for (final choice in {
          'Horizontal Split': LibraryDetailsLayout.bottom,
          'No Details': LibraryDetailsLayout.hidden,
          'Vertical Split': LibraryDetailsLayout.right,
        }.entries) {
          await tester.tap(trigger);
          await tester.pumpAndSettle();
          final options = find.byType(PopupMenuItem<LibraryDetailsLayout>);
          expect(tester.getTopLeft(find.text('Horizontal Split')).dy,
              lessThan(tester.getTopLeft(find.text('Vertical Split')).dy));
          expect(tester.getSize(options.first).height, 30);
          await tester.tap(find.text(choice.key));
          await tester.pumpAndSettle();
          expect(layout, choice.value);
          expect(tester.takeException(), isNull);
        }
        await mouse.removePointer();
      });
    }
  }

  testWidgets('View popup exposes visible hover and a hand cursor',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Align(
      alignment: Alignment.topLeft,
      child: LibraryViewModeDropdown(
          viewMode: LibraryViewMode.grid, iconOnly: true, onChanged: (_) {}),
    ))));
    final trigger = find.byKey(const Key('library-view-mode-dropdown'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(790, 590));
    await mouse.moveTo(tester.getCenter(trigger));
    await tester.pumpAndSettle();
    expect(RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.click);
    final surface =
        find.descendant(of: trigger, matching: find.byType(AnimatedContainer));
    final decoration =
        tester.widget<AnimatedContainer>(surface).decoration as BoxDecoration;
    expect(
        decoration.color, libraryToolbarControlHover(tester.element(trigger)));
    await mouse.removePointer();
  });

  testWidgets('menu-only dense controls stay interactive and open their menu',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Align(
      alignment: Alignment.topLeft,
      child: LibraryDenseMenuButton<String>(
          label: 'Tools',
          icon: Icons.tune,
          entries: const [
            LibraryDenseMenuEntry(value: 'entry', label: 'Action', icon: null)
          ],
          onSelected: (_) {}),
    ))));
    final trigger = find.byType(LibraryDenseMenuButton<String>);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(790, 590));
    await mouse.moveTo(tester.getCenter(trigger));
    await tester.pumpAndSettle();
    expect(RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.click);
    final button =
        tester.widget<LibraryDenseButton>(find.byType(LibraryDenseButton));
    expect(button.menuTrigger, isTrue);
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    expect(find.text('Action'), findsOneWidget);
    await mouse.removePointer();
  });
}
