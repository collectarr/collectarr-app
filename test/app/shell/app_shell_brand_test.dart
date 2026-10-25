import 'package:collectarr_app/app/shell/app_shell_brand.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final platform in [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
    TargetPlatform.android,
    TargetPlatform.iOS
  ]) {
    testWidgets('brand identifies native $platform even at a narrow width',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(
              body: SizedBox(
                  width: 180,
                  child: AppShellBrand(
                    icon: AppIcons.user,
                    kindTitle: 'Music',
                    iconKey: Key('brand.icon'),
                    titleKey: Key('brand.title'),
                  )))));
      final mobile =
          platform == TargetPlatform.android || platform == TargetPlatform.iOS;
      expect(find.text(mobile ? 'MOBILE' : 'DESKTOP'), findsOneWidget);
      expect(find.text('CLR MUSIC'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant({platform}));
  }
}
