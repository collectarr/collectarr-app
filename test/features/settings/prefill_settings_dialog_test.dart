import 'package:collectarr_app/ui/adaptive/mobile_page.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/settings/prefill_settings_dialog.dart';
import 'package:collectarr_app/features/library/add/models/prefill_defaults.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';

import '../../support/fixtures/test_constants.dart';
import 'package:collectarr_app/features/library/ui/primitives/dropdown_pick_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/models/common_draft.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/form_controls.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('prefill retains Condition and uses today only when enabled', () async {
    const defaults = PrefillDefaults(
        alwaysShow: false,
        fillPurchaseDateWithToday: true,
        personalValues: {'condition': 'Good'});
    await defaults.save(CatalogMediaKind.music);
    final stored = await PrefillDefaults.load(CatalogMediaKind.music);
    expect(stored.alwaysShow, isFalse);
    expect(stored.fillPurchaseDateWithToday, isTrue);
    final draft = stored.applyTo(const LibraryAddCommonDraft());
    expect(draft.condition, 'Good');
    expect(draft.purchaseDate!.day, DateTime.now().day);
    expect(
        (await PrefillDefaults.load(CatalogMediaKind.book)).alwaysShow, isTrue);
  });

  test('ignores unsupported kind-entry prefill keys', () async {
    SharedPreferences.setMockInitialValues({
      'collectarr.prefill.condition': 'Very Fine',
      'collectarr.prefill.grade': '9.6',
      'collectarr.prefill.read_status': 'read',
      'collectarr.prefill.tag_list': ['favorite'],
    });

    final defaults = await PrefillDefaults.load();

    expect(defaults.locationId, isNull);
    expect(defaults.tags, ['favorite']);
  });

  testWidgets('prefill settings dialog saves structured location ids',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-1',
            name: 'Short Box 1',
            sortOrder: const Value(1),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [localDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: Scaffold(
            body: PrefillSettingsDialog(
                accent: Colors.orange, kind: CatalogMediaKind.music),
          ),
        ),
      ),
    );

    await pumpUntilSettled(tester);
    expect(
        find.ancestor(
            of: find.byTooltip('Manage Locations'),
            matching: find.byType(LibraryDropdownPickField<String>)),
        findsOneWidget,
        reason: 'Location uses the boxed pick field like the editor');
    await tester.tap(find.byTooltip('Manage Locations'));
    await pumpUntilSettled(tester);
    expect(find.text('Select Location'), findsOneWidget);
    await tester.tap(find.text('Short Box 1').last);
    await pumpUntilSettled(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Save').first);
    await pumpUntilSettled(tester);

    final defaults = await PrefillDefaults.load();
    expect(defaults.locationId, 'loc-1');
  });

  testWidgets('Add confirmation edits Condition and persists prefill choices',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    PrefillDefaults? result;
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
          home: Scaffold(
              body: Builder(
        builder: (context) => TextButton(
            onPressed: () async {
              result = await showPrefillSettingsDialog(
                  context: context,
                  accent: Colors.orange,
                  kind: CatalogMediaKind.music,
                  confirmLabel: 'Add');
            },
            child: const Text('Confirm add')),
      ))),
    ));
    await tester.tap(find.text('Confirm add'));
    await pumpUntilSettled(tester);
    final condition = find.byWidgetPredicate((widget) =>
        widget is SingleValuePickField && widget.label == 'Condition');
    await tester.enterText(
        find.descendant(of: condition, matching: find.byType(TextFormField)),
        'Good');
    await tester.tap(find.text('Fill with today'));
    await tester.tap(find.textContaining('Always show'));
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await pumpUntilSettled(tester);
    expect(result!.personalValues['condition'], 'Good');
    expect(result!.fillPurchaseDateWithToday, isTrue);
    expect(result!.alwaysShow, isFalse);
    expect(find.byType(PrefillSettingsDialog), findsNothing);
  });

  testWidgets('Games pre-fill offers completeness, owner and quantity',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    PrefillDefaults? result;
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
          home: Scaffold(
              body: Builder(
        builder: (context) => TextButton(
            onPressed: () async {
              result = await showPrefillSettingsDialog(
                  context: context,
                  accent: Colors.red,
                  kind: CatalogMediaKind.game);
            },
            child: const Text('Open')),
      ))),
    ));
    await tester.tap(find.text('Open'));
    await pumpUntilSettled(tester);

    expect(find.text('Completeness'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is SingleValuePickField && widget.label == 'Condition'),
        findsNothing);

    await tester.tap(find.text('CIB'));
    await pumpUntilSettled(tester);
    await tester.enterText(find.byKey(const ValueKey('prefill-quantity')), '2');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(result!.personalValues['game_completeness'], 'cib');
    expect(result!.personalValues['game_has_box'], isTrue);
    expect(result!.personalValues['game_has_manual'], isTrue);
    expect(result!.personalValues['quantity'], 2);
    expect(result!.personalValues.containsKey('market_value_cents'), isFalse);
  });

  testWidgets('Fill with today shows today read-only at once', (tester) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(
          home: Scaffold(
              body: PrefillSettingsDialog(
                  accent: Colors.red, kind: CatalogMediaKind.game))),
    ));
    await pumpUntilSettled(tester);

    await tester.tap(find.text('Fill with today'));
    await tester.pump();

    final year = find.descendant(
        of: find.byType(LibraryPartialDateInput),
        matching: find.text('${DateTime.now().year}'));
    expect(year, findsOneWidget);
    final field = tester.widget<TextField>(
        find.ancestor(of: year, matching: find.byType(TextField)));
    expect(field.enabled, isFalse);
  });

  test('catalog pre-fill values are kept per kind', () async {
    const defaults = PrefillDefaults(
        catalogValues: {'series_title': 'Brick Saga', 'release_region': 'EU'});
    await defaults.save(CatalogMediaKind.game);
    expect((await PrefillDefaults.load(CatalogMediaKind.game)).catalogValues,
        {'series_title': 'Brick Saga', 'release_region': 'EU'});
    expect((await PrefillDefaults.load(CatalogMediaKind.comic)).catalogValues,
        isEmpty);
  });

  testWidgets('Games Pre-fill fields offers Main, Edition and Personal',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
          home: Scaffold(
              body: Builder(
        builder: (context) => TextButton(
            onPressed: () => showPrefillSettingsDialog(
                context: context,
                accent: Colors.red,
                kind: CatalogMediaKind.game),
            child: const Text('Open')),
      ))),
    ));
    await tester.tap(find.text('Open'));
    await pumpUntilSettled(tester);
    await tester.tap(find.byTooltip('Pre-fill fields'));
    await pumpUntilSettled(tester);

    for (final id in [
      'series',
      'platform',
      'genre',
      'audience_rating',
      'edition',
      'format',
      'region',
      'condition',
      'game_completed',
      'game_completed_date_parts',
      'game_storage_slot',
    ]) {
      expect(find.byKey(ValueKey('prefill-field-$id')), findsOneWidget,
          reason: id);
    }
    await tester.tap(find.byKey(const ValueKey('prefill-field-region')));
    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await pumpUntilSettled(tester);
    expect(find.text('Region'), findsWidgets);
  });

  testWidgets('Pre-fill fields hides a field and stops filling it',
      (tester) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      'collectarr.prefill.game.personal': '{"quantity": 3}',
    });
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    PrefillDefaults? result;
    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
          home: Scaffold(
              body: Builder(
        builder: (context) => TextButton(
            onPressed: () async {
              result = await showPrefillSettingsDialog(
                  context: context,
                  accent: Colors.red,
                  kind: CatalogMediaKind.game);
            },
            child: const Text('Open')),
      ))),
    ));
    await tester.tap(find.text('Open'));
    await pumpUntilSettled(tester);
    expect(find.widgetWithText(TextButton, 'Cancel'), findsNothing);

    await tester.tap(find.byTooltip('Pre-fill fields'));
    await pumpUntilSettled(tester);
    expect(find.text('Pre-fill fields'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('prefill-field-quantity')));
    await tester.tap(find.widgetWithText(FilledButton, 'OK'));
    await pumpUntilSettled(tester);

    expect(find.byKey(const ValueKey('prefill-quantity')), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await pumpUntilSettled(tester);

    expect(result!.fields, isNot(contains('quantity')));
    expect(result!.personalValues.containsKey('quantity'), isFalse);
    expect((await PrefillDefaults.load(CatalogMediaKind.game)).fields,
        result!.fields);
  });

  testWidgets('PrefillSettingsDialog renders MobilePage on native mobile phone',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(
        home: Scaffold(
          body: PrefillSettingsDialog(
            accent: Colors.teal,
            kind: CatalogMediaKind.comic,
          ),
        ),
      ),
    ));
    await pumpUntilSettled(tester);

    expect(find.byType(MobilePage), findsOneWidget);
    expect(find.text('Pre-fill Comic Details'), findsOneWidget);
    expect(find.text('Always show'), findsOneWidget);
  });

  testWidgets(
      'PrefillSettingsDialog renders centered card on native mobile tablet',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(
        home: Scaffold(
          body: PrefillSettingsDialog(
            accent: Colors.teal,
            kind: CatalogMediaKind.comic,
          ),
        ),
      ),
    ));
    await pumpUntilSettled(tester);

    expect(find.byType(MobilePage), findsOneWidget);
    expect(find.text('Pre-fill Comic Details'), findsOneWidget);
    expect(find.text('Always show'), findsOneWidget);
  });
}
