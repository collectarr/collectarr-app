import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/settings/custom_fields_display_settings.dart';
import 'package:collectarr_app/features/settings/custom_fields_settings.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalDatabase db;
  late CustomFieldRepository repo;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = LocalDatabase(NativeDatabase.memory());
    repo = CustomFieldRepository(db);
  });
  tearDown(() => db.close());

  CustomFieldDefinition definition(String id, String? kind, int order) =>
      CustomFieldDefinition(
          id: id,
          name: id,
          mediaKind: kind,
          fieldType: 'text',
          sortOrder: order,
          createdAt: DateTime.utc(2026));

  Future<void> openPage(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
          home: Scaffold(
              body: Builder(
                  builder: (context) => TextButton(
                      onPressed: () => showCustomFieldsManagementPage(
                          context: context,
                          db: db,
                          mediaKind: 'music',
                          accent: Colors.orange),
                      child: const Text('Open manager'))))),
    ));
    await tester.tap(find.text('Open manager'));
    await tester.pumpAndSettle();
  }

  Future<void> chooseType(WidgetTester tester, String type) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Add Custom Field'));
    await tester.pumpAndSettle();
    final choice = find.byKey(ValueKey('custom_field.type.$type'));
    await tester.ensureVisible(choice);
    await tester.tap(choice);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'page navigation and fixed choices create, edit and delete persist',
      (tester) async {
    await openPage(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Manage Custom Fields'), findsOneWidget);
    await chooseType(tester, 'fixedButtons');
    await tester.enterText(find.byType(TextFormField).first, 'Sleeve');
    for (var i = 0; i < 5; i++) {
      await tester.ensureVisible(find.byTooltip('Add field value'));
      await tester.tap(find.byTooltip('Add field value'));
      await tester.pumpAndSettle();
      final option = find.byKey(ValueKey('custom_field.option.$i.${i + 1}'));
      await tester.ensureVisible(option);
      await tester.enterText(
          find.descendant(of: option, matching: find.byType(TextFormField)),
          'Value $i');
    }
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Add'));
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(find.text('Maximum 4 options'), findsOneWidget);
    for (var i = 5; i > 2; i--) {
      await tester.ensureVisible(find.byTooltip('Remove field value $i'));
      await tester.tap(find.byTooltip('Remove field value $i'));
      await tester.pumpAndSettle();
    }
    final options = find.byType(TextFormField);
    await tester.enterText(options.at(1), 'Mint');
    await tester.enterText(options.at(2), 'Good');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Add'));
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    var saved = (await repo.listDefinitions(mediaKind: 'music')).single;
    expect(saved.name, 'Sleeve');
    expect(saved.optionValues, ['Mint', 'Good']);
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextFormField).first, 'Sleeve condition');
    expect(
        tester.widget<TextFormField>(find.byType(TextFormField).at(1)).enabled,
        isFalse);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    saved = (await repo.listDefinitions()).single;
    expect(saved.name, 'Sleeve condition');
    expect(saved.optionValues, ['Mint', 'Good']);
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(await repo.listDefinitions(), isEmpty);
    await tester.tap(find.widgetWithText(TextButton, 'Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open manager'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kind filtering preserves global fields and narrow layouts',
      (tester) async {
    await repo.upsertDefinition(definition('Global', null, 0));
    await repo.upsertDefinition(definition('Music only', 'music', 1));
    await repo.upsertDefinition(definition('Movie only', 'movie', 2));
    await openPage(tester);
    expect(find.text('Movie only'), findsNothing);
    expect(find.text('Global'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect((await repo.listDefinitions()).first.mediaKind, isNull);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final width in [1400.0, 900.0, 480.0]) {
      tester.view.physicalSize = Size(width, 650);
      await tester.pumpAndSettle();
      await chooseType(tester, 'weight');
      expect(find.text('Storage Type'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('tab name and visibility survive closing the page',
      (tester) async {
    await openPage(tester);
    await tester.tap(find.byTooltip('Custom Fields settings'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'My Details');
    await tester.tap(find.text('No'));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    final display = await CustomFieldsDisplaySettings.read('music');
    expect(display.tabName, 'My Details');
    expect(display.showEditTab, isFalse);
    await tester.tap(find.widgetWithText(TextButton, 'Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open manager'));
    await tester.pumpAndSettle();
    expect(find.text('My Details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
      'every measured unit supported by the editor persists without conversion',
      () async {
    for (final type in [
      CustomFieldValueType.weight,
      CustomFieldValueType.size
    ]) {
      for (final unit in type.allowedUnits) {
        final def = CustomFieldDefinition(
            id: '${type.name}-$unit',
            name: 'Measurement',
            fieldType: type.apiValue,
            options: encodeCustomFieldOptions([unit]),
            createdAt: DateTime.utc(2026));
        await repo.upsertDefinition(def);
        expect(
            (await repo.listDefinitions())
                .firstWhere((d) => d.id == def.id)
                .unit,
            unit);
      }
    }
  });

  test('reordering visible fields preserves other kinds and validates ids',
      () async {
    for (final def in [
      definition('First', 'music', 0),
      definition('Other', 'movie', 1),
      definition('Second', 'music', 2)
    ]) {
      await repo.upsertDefinition(def);
    }
    await repo.reorderDefinitions(['Second', 'First']);
    expect((await repo.listDefinitions()).map((d) => d.id),
        ['Second', 'Other', 'First']);
    await expectLater(
        repo.reorderDefinitions(['First', 'First']), throwsArgumentError);
    await expectLater(
        repo.reorderDefinitions(['unknown']), throwsArgumentError);
    expect((await repo.listDefinitions()).map((d) => d.id),
        ['Second', 'Other', 'First']);
  });

  test(
      'type configuration round trips and rejects invalid fixed choices or units',
      () async {
    for (final type in [
      CustomFieldValueType.decimal,
      CustomFieldValueType.percentage,
      CustomFieldValueType.duration,
      CustomFieldValueType.weight,
      CustomFieldValueType.size,
      CustomFieldValueType.fixedButtons,
      CustomFieldValueType.fixedList
    ]) {
      final def = CustomFieldDefinition(
          id: type.name,
          name: type.label,
          fieldType: type.apiValue,
          options: type.hasUnit
              ? encodeCustomFieldOptions(
                  [type == CustomFieldValueType.weight ? 'lb' : 'in'])
              : type.isFixedChoice
                  ? encodeCustomFieldOptions(['A', 'B'])
                  : null,
          createdAt: DateTime.utc(2026));
      await repo.upsertDefinition(def);
      final saved =
          (await repo.listDefinitions()).firstWhere((d) => d.id == type.name);
      expect(saved.valueType, type);
      expect(saved.options, def.options);
    }
    final percentage = (await repo.listDefinitions())
        .firstWhere((d) => d.valueType == CustomFieldValueType.percentage);
    expect(displayCustomFieldValue(percentage, '12.50'), '12.50%');
    final weight = (await repo.listDefinitions())
        .firstWhere((d) => d.valueType == CustomFieldValueType.weight);
    expect(displayCustomFieldValue(weight, '1.25'), '1.25 lb');
    expect(
        () => repo.upsertDefinition(CustomFieldDefinition(
            id: 'bad',
            name: 'Bad',
            fieldType: 'fixedButtons',
            options: encodeCustomFieldOptions(['1', '2', '3', '4', '5']),
            createdAt: DateTime.utc(2026))),
        throwsArgumentError);
    expect(
        () => repo.upsertDefinition(CustomFieldDefinition(
            id: 'bad',
            name: 'Bad',
            fieldType: 'weight',
            options: encodeCustomFieldOptions(['stone']),
            createdAt: DateTime.utc(2026))),
        throwsArgumentError);
  });
}
