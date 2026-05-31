import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('single value pick field exposes an inline picker menu',
      (tester) async {
    final controller = TextEditingController(text: 'Publisher A');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleValuePickField(
            controller: controller,
            options: const ['Publisher A', 'Publisher B'],
            label: 'Publisher',
          ),
        ),
      ),
    );

    expect(find.byTooltip('Pick Publisher'), findsOneWidget);

    await tester.tap(find.byTooltip('Pick Publisher'));
    await tester.pumpAndSettle();

    expect(find.text('Publisher B'), findsOneWidget);

    await tester.tap(find.text('Publisher B'));
    await tester.pumpAndSettle();

    expect(controller.text, 'Publisher B');
    expect(find.byTooltip('Browse Publisher'), findsNothing);
  });

  testWidgets('single value pick field browse action opens picker dialog',
      (tester) async {
    final controller = TextEditingController(text: 'Publisher A');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleValuePickField(
            controller: controller,
            options: const ['Publisher A', 'Publisher B'],
            label: 'Publisher',
            showPickerListAction: true,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Pick Publisher'), findsOneWidget);
    expect(find.byTooltip('Browse Publisher'), findsOneWidget);

    await tester.tap(find.byTooltip('Browse Publisher'));
    await tester.pumpAndSettle();

    expect(find.text('Pick Publisher'), findsOneWidget);
  });

  testWidgets('single value pick field does not auto-list options on focus',
      (tester) async {
    final controller = TextEditingController(text: 'Publisher A');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleValuePickField(
            controller: controller,
            options: const ['Publisher A', 'Publisher B'],
            label: 'Publisher',
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(find.text('Pick Publisher'), findsNothing);
    expect(find.text('Publisher B'), findsNothing);
  });
}