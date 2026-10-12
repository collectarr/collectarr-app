import 'dart:ui';

import 'package:collectarr_app/features/library/workspace/chrome/library_dense_controls.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
