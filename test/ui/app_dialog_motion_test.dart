import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dialog fades for 200ms while backdrop settles in 100ms',
      (tester) async {
    AppDialogRoute<void>? route;
    await tester.pumpWidget(MaterialApp(
        home: Builder(
      builder: (context) => TextButton(
          onPressed: () => showAppDialog<void>(
                context: context,
                builder: (context) {
                  route = ModalRoute.of(context)! as AppDialogRoute<void>;
                  return const Dialog(child: Text('Motion dialog'));
                },
              ),
          child: const Text('Open')),
    )));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(route!.animation!.value, closeTo(.5, .01));
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Container && widget.color == Colors.black54),
        findsOneWidget);
    await tester.pumpAndSettle();
    route!.navigator!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(route!.animation!.value, closeTo(.5, .01));
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Container && widget.color?.a == 0),
        findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Motion dialog'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
