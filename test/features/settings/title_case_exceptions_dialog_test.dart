import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/core/utils/title_case.dart';
import 'package:collectarr_app/features/settings/title_case_exceptions_dialog.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'exceptions support immediate toggle, add, edit, cancel and delete',
      (tester) async {
    final original = ['the', 'of'];
    var words = [...original];
    var disabled = <String>[];
    var saves = 0;
    const accent = Color(0xffe82b48);
    await tester.pumpWidget(MaterialApp(
      theme: buildAppShellTheme(),
      home: Scaffold(
          body: Builder(
              builder: (context) => TextButton(
                    onPressed: () => showTitleCaseExceptionsDialog(context,
                        exceptions: original,
                        disabledExceptions: const [],
                        accent: accent, onChanged: (next, inactive) async {
                      words = next;
                      disabled = inactive;
                      saves++;
                    }),
                    child: const Text('Open'),
                  ))),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Auto Cap Exceptions'), findsOneWidget);
    expect(
        tester
            .widget<AccentDialogHeader>(find.byType(AccentDialogHeader))
            .accent,
        accent);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.text('of'));
    await tester.pumpAndSettle();
    expect(words, ['the', 'of']);
    expect(disabled, ['of']);
    expect(
        applyTitleCase(
            'return of the jedi',
            UiPreferences(
                    titleCaseExceptions: words,
                    disabledTitleCaseExceptions: disabled)
                .titleCase),
        'Return Of the Jedi');

    await tester.tap(find.text('Add new exception'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('exception-word')), 'AND');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(words, ['the', 'of', 'and']);
    await tester.tap(find.byTooltip('Edit of'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('exception-word')), 'FOR');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(words, ['the', 'for', 'and']);
    expect(disabled, ['for']);

    await tester.tap(find.text('Add new exception'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('exception-word')), 'THE');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('This exception already exists.'), findsOneWidget);
    expect(saves, 3);
    await tester.tap(find.byTooltip('Cancel edit'));
    await tester.pumpAndSettle();
    expect(words, ['the', 'for', 'and']);
    await tester.tap(find.byTooltip('Delete the'));
    await tester.pumpAndSettle();
    expect(words, ['for', 'and']);
    expect(disabled, ['for']);
    expect(original, ['the', 'of']);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Auto Cap Exceptions'), findsNothing);
    expect(saves, 4);
    expect(tester.takeException(), isNull);
  });

  test('exception updates normalize words and discard stale disabled entries',
      () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(uiPreferencesProvider);
    await Future<void>.delayed(Duration.zero);
    await container.read(uiPreferencesProvider.notifier).setTitleCaseExceptions(
        [' THE ', 'of', 'the'],
        disabled: ['OF', 'missing']);
    final restored = await const UiPreferencesStore().read();
    expect(restored.titleCaseExceptions, ['the', 'of']);
    expect(restored.disabledTitleCaseExceptions, ['of']);
  });

  test(
      'disabled words persist and stop affecting capitalization without being deleted',
      () async {
    SharedPreferences.setMockInitialValues({});
    const store = UiPreferencesStore();
    final defaults = await store.read();
    expect(defaults.disabledTitleCaseExceptions, isEmpty);
    final edited = defaults.copyWith(
        titleCaseExceptions: ['of', 'the'],
        disabledTitleCaseExceptions: ['of']);
    await store.write(edited);
    final restored = await store.read();
    expect(restored.titleCaseExceptions, ['of', 'the']);
    expect(restored.disabledTitleCaseExceptions, ['of']);
    expect(applyTitleCase('return of the jedi', restored.titleCase),
        'Return Of the Jedi');
    expect(
        applyTitleCase('return of the jedi',
            restored.copyWith(disabledTitleCaseExceptions: []).titleCase),
        'Return of the Jedi');
  });
}
