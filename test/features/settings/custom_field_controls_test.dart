import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> control(WidgetTester tester, CustomFieldValueType type,
      ValueChanged<Map<String, String?>> onChanged,
      {List<String> options = const []}) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Form(
      child: CustomFieldsEditSection(definitions: [
        CustomFieldDefinition(
          id: 'field',
          name: 'Field',
          fieldType: type.apiValue,
          options: options.isEmpty ? null : encodeCustomFieldOptions(options),
          createdAt: DateTime.utc(2026),
        )
      ], values: const {}, accent: Colors.orange, onChanged: onChanged),
    ))));
    await tester.pumpAndSettle();
  }

  testWidgets('numeric editors distinguish integers and two-decimal input',
      (tester) async {
    Map<String, String?> values = {};
    await control(
        tester, CustomFieldValueType.number, (value) => values = Map.of(value));
    await tester.enterText(find.byType(TextFormField), '12');
    expect(values['field'], '12');
    await tester.enterText(find.byType(TextFormField), '12.5');
    expect(values['field'], '12');
    await tester.pumpWidget(const SizedBox.shrink());
    await control(tester, CustomFieldValueType.decimal,
        (value) => values = Map.of(value));
    await tester.enterText(find.byType(TextFormField), '12.50');
    expect(values['field'], '12.50');
    await tester.enterText(find.byType(TextFormField), '12.501');
    expect(values['field'], '12.50');
  });

  testWidgets('fixed buttons toggle their value without a vocabulary picker',
      (tester) async {
    Map<String, String?> values = {};
    await control(tester, CustomFieldValueType.fixedButtons,
        (value) => values = Map.of(value),
        options: ['Mint', 'Good']);
    await tester.tap(find.text('Good'));
    await tester.pump();
    expect(values['field'], 'Good');
    await tester.tap(find.text('Good'));
    await tester.pump();
    expect(values['field'], isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'partial dates preserve year precision and durations allow more than 24 hours',
      (tester) async {
    Map<String, String?> values = {};
    await control(
        tester, CustomFieldValueType.date, (value) => values = Map.of(value));
    await tester.enterText(find.byType(TextFormField).first, '2025');
    expect(values['field'], '2025');
    await tester.enterText(find.byType(TextFormField).at(1), '02');
    expect(values['field'], '2025-02');
    await tester.pumpWidget(const SizedBox.shrink());
    await control(tester, CustomFieldValueType.duration,
        (value) => values = Map.of(value));
    await tester.enterText(find.byType(TextFormField).first, '27');
    await tester.enterText(find.byType(TextFormField).last, '15');
    final form = tester.state<FormState>(find.byType(Form));
    expect(form.validate(), isTrue);
    expect(values['field'], '27:15');
    await tester.enterText(find.byType(TextFormField).last, '60');
    expect(form.validate(), isFalse);
  });
}
