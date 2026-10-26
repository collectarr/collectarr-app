import 'dart:io';

import 'package:collectarr_app/core/localization/app_languages.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/ui/theme/shell_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every application language has its flag', () {
    expect(kAppLanguages.map((language) => language.locale), [
      'en-US', 'nl-NL', 'de-DE', 'fr-FR', 'es-ES', 'hu-HU', //
      'sr-RS', 'da-DK', 'it-IT', 'sv-SE', 'sk-SK', 'pt-PT',
    ]);
    for (final language in kAppLanguages) {
      final flag = File(language.flagAsset);
      expect(flag.existsSync(), isTrue, reason: language.flagAsset);
      expect(flag.readAsStringSync(), contains('viewBox="0 0 640 480"'),
          reason: language.flagAsset);
    }
  });

  testWidgets('only translated languages can be chosen', (tester) async {
    AppLanguage? chosen;
    await tester.pumpWidget(MaterialApp(
      theme: buildAppShellTheme(),
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: SettingsSelect<AppLanguage>(
            value: kAppLanguages.first,
            values: kAppLanguages,
            labelOf: (language) => language.nativeName,
            leadingOf: (language) =>
                SvgPicture.asset(language.flagAsset, width: 21, height: 16),
            isOptionEnabled: (language) => language.translated,
            onChanged: (language) => chosen = language,
          ),
        ),
      ),
    ));
    expect(find.byType(SvgPicture), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.byType(SvgPicture), findsNWidgets(kAppLanguages.length + 1));

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(chosen, isNull);

    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect(chosen?.locale, 'en-US');
  });
}
