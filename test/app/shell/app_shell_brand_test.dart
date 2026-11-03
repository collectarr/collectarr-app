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
    testWidgets('brand omits the platform at a narrow width on $platform',
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
      for (final label in ['MOBILE', 'DESKTOP', 'WEB']) {
        expect(find.text(label), findsNothing);
      }
      expect(find.text('CLR MUSIC'), findsOneWidget);
      if (platform == TargetPlatform.android ||
          platform == TargetPlatform.iOS) {
        await tester.pumpWidget(const MaterialApp(
            home: Scaffold(
                body: AppShellBrand(
                    icon: AppIcons.user,
                    kindTitle: 'Music',
                    iconKey: Key('brand.icon'),
                    titleKey: Key('brand.title'),
                    showIcon: false))));
        expect(find.byKey(const Key('brand.icon')), findsNothing);
        expect(find.text('CLR MUSIC'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant({platform}));
  }
}
