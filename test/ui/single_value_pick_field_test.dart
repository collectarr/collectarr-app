import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('single value pick field exposes a picker dialog',
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

    expect(find.text('Pick Publisher'), findsOneWidget);
    expect(find.text('Publisher B'), findsOneWidget);

    await tester.tap(find.text('Publisher B').last);
    await tester.pumpAndSettle();

    expect(controller.text, 'Publisher B');
  });

  testWidgets('single value pick field shows all suffix actions',
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
            onManage: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Pick Publisher'), findsOneWidget);
    expect(find.byTooltip('Clear Publisher'), findsOneWidget);
    expect(find.byTooltip('Manage Publisher'), findsOneWidget);
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