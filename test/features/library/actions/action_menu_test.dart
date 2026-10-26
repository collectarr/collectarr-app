import 'dart:async';
import 'package:collectarr_app/features/library/actions/action_menu.dart';
import 'package:collectarr_app/features/library/actions/ui_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'menu disables while running and reports errors without a handler',
      (tester) async {
    final pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ActionMenu<String>(
      contextValue: 'fixture',
      placement: UiActionPlacement.itemMenu,
      actions: [
        _TestAction(
            id: 'save',
            label: 'Save item',
            placement: UiActionPlacement.itemMenu,
            onRun: () {
              calls++;
              return pending.future;
            })
      ],
    ))));
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save item'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(
        tester
            .widget<PopupMenuButton<UiAction<String>>>(
                find.byType(PopupMenuButton<UiAction<String>>))
            .enabled,
        isFalse);
    pending.completeError(StateError('failed save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Save item failed:'), findsOneWidget);
    expect(
        tester
            .widget<PopupMenuButton<UiAction<String>>>(
                find.byType(PopupMenuButton<UiAction<String>>))
            .enabled,
        isTrue);
  });

  testWidgets('renders only visible actions for its placement', (tester) async {
    var runs = 0;
    final actions = <UiAction<String>>[
      _TestAction(
        id: 'visible',
        label: 'Visible action',
        placement: UiActionPlacement.itemMenu,
        onRun: () => runs++,
      ),
      _TestAction(
        id: 'hidden',
        label: 'Hidden action',
        placement: UiActionPlacement.itemMenu,
        visible: false,
        onRun: () => runs++,
      ),
      _TestAction(
        id: 'other-placement',
        label: 'Other placement',
        placement: UiActionPlacement.toolbar,
        onRun: () => runs++,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionMenu<String>(
            contextValue: 'fixture',
            actions: actions,
            placement: UiActionPlacement.itemMenu,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();

    expect(find.text('Visible action'), findsOneWidget);
    expect(find.text('Hidden action'), findsNothing);
    expect(find.text('Other placement'), findsNothing);

    await tester.tap(find.text('Visible action'));
    await tester.pump();
    expect(runs, 1);
  });
}

final class _TestAction implements UiAction<String> {
  _TestAction({
    required this.id,
    required this.label,
    required this.placement,
    required this.onRun,
    this.visible = true,
  });

  @override
  final String id;

  @override
  final String label;

  @override
  final UiActionPlacement placement;

  final FutureOr<void> Function() onRun;
  final bool visible;

  @override
  IconData get icon => Icons.play_arrow;

  @override
  bool isVisible(String context) => visible;

  @override
  bool isEnabled(String context) => true;

  @override
  FutureOr<void> run(String context) => onRun();
}
