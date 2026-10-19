import 'package:collectarr_app/ui/app_dark_chrome.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppThemePalette> _chromePalette(
    WidgetTester tester, AppThemePalette palette) async {
  late AppThemePalette seen;
  await tester.pumpWidget(MaterialApp(
    theme: buildAppShellTheme(palette: palette),
    home: AppDarkChrome(
      accent: const Color(0xFFE23149),
      child: Builder(builder: (context) {
        seen = appPalette(context);
        return const SizedBox();
      }),
    ),
  ));
  return seen;
}

void main() {
  testWidgets('light theme keeps chrome on the dark skin with the kind accent',
      (tester) async {
    final palette = await _chromePalette(tester, kLightAppThemePalette);
    expect(palette.isDark, isTrue);
    expect(palette.accent, const Color(0xFFE23149));
  });

  testWidgets('dark theme leaves chrome unchanged', (tester) async {
    final palette = await _chromePalette(tester, kDefaultAppThemePalette);
    expect(palette.isDark, isTrue);
    expect(palette.accent, kDefaultAppThemePalette.accent);
  });

  test('light content follows the reference skin', () {
    const palette = kLightAppThemePalette;
    expect(palette.canvas, const Color(0xFFF6F6F6));
    expect(palette.panel, const Color(0xFFF9F9F9));
    expect(palette.panelRaised, Colors.white);
    expect(palette.textPrimary, const Color(0xFF333333));
    expect(palette.utilityAction, const Color(0xFF5EB1DE));
    expect(palette.itemTitle, const Color(0xFF0082A6));
  });
}
