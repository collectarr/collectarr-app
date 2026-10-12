import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/settings/custom_field_editor_dialog.dart';
import 'package:collectarr_app/features/settings/custom_field_type_picker.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final type in CustomFieldValueType.values) {
    testWidgets(
        '${type.name} definition and isolated preview render without database access',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: CustomFieldEditorDialog(
                  initialType: type,
                  initialDisplay: const CustomFieldDisplaySettings()))));
      await tester.pumpAndSettle();
      expect(find.text('Field Name'), findsWidgets);
      final configured = ![
        CustomFieldValueType.currency,
        CustomFieldValueType.percentage,
        CustomFieldValueType.weight,
        CustomFieldValueType.size
      ].contains(type);
      expect(find.text('Preview'), configured ? findsOneWidget : findsNothing);
      expect(find.byType(CustomFieldsEditSection),
          configured ? findsOneWidget : findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('chooser retains additional Collectarr types behind disclosure',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CustomFieldTypePicker())));
    expect(find.byKey(const ValueKey('custom_field.type.url')), findsNothing);
    await tester.tap(find.text('More field types'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('custom_field.type.url')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('custom_field.type.time')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('custom_field.type.person')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('numeric storage choice is returned with the new definition',
      (tester) async {
    CustomFieldEditorResult? result;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () async {
                      result = await showDialog<CustomFieldEditorResult>(
                          context: context,
                          builder: (_) => const CustomFieldEditorDialog(
                              initialType: CustomFieldValueType.currency,
                              initialMediaKind: 'music',
                              initialDisplay: CustomFieldDisplaySettings()));
                    },
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Budget');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a Storage Type'), findsOneWidget);
    await tester.tap(find.byTooltip('Choose Storage Type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Number').last);
    await tester.pumpAndSettle();
    expect(find.text('Choose a Storage Type'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(result?.display.numericStorage, CustomFieldNumericStorage.number);
    expect(result?.definition.valueType, CustomFieldValueType.currency);
    expect(tester.takeException(), isNull);
  });
  test('all multi-value presentations and numeric storage survive preferences',
      () async {
    for (final control in CustomFieldMultiValueControl.values) {
      final settings = CustomFieldDisplaySettings(
          pluralName: 'People',
          currencyCode: 'SGD',
          multiValueControl: control,
          numericStorage: CustomFieldNumericStorage.number,
          multiValueDisplay: CustomFieldMultiValueDisplay.list);
      await settings.save('field');
      final restored = await CustomFieldDisplaySettings.read('field');
      expect(restored.multiValueControl, control);
      expect(restored.currencyCode, 'SGD');
      expect(restored.numericStorage, CustomFieldNumericStorage.number);
      expect(restored.multiValueDisplay, CustomFieldMultiValueDisplay.list);
    }
    await CustomFieldDisplaySettings.delete('field');
    expect((await CustomFieldDisplaySettings.read('field')).multiValueDisplay,
        CustomFieldMultiValueDisplay.separator);
  });
}
