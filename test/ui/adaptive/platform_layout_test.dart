import 'package:collectarr_app/ui/adaptive/adaptive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final platform in TargetPlatform.values) {
    for (final isWeb in [false, true]) {
      test(
          '$platform on ${isWeb ? 'web' : 'native'} resolves presentation independently of size',
          () {
        final expected = !isWeb &&
                (platform == TargetPlatform.android ||
                    platform == TargetPlatform.iOS)
            ? AppPresentationPlatform.nativeMobile
            : AppPresentationPlatform.desktopWeb;
        final policy =
            AppPresentationPlatform.fromTarget(platform, isWeb: isWeb);
        expect(policy, expected);
        expect(policy.isNativeMobile,
            expected == AppPresentationPlatform.nativeMobile);
        for (final width in [390.0, 900.0, 1600.0]) {
          final size = AppWindowClass.fromSize(Size(width, 844));
          expect(size.widthClass.isCompact, width < 600);
          expect(AppPresentationPlatform.fromTarget(platform, isWeb: isWeb),
              policy);
        }
      });
    }
  }
  testWidgets('runtime policy follows the native platform at every width',
      (tester) async {
    expect(
        appPresentationPlatform.isNativeMobile,
        defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final width in [390.0, 1024.0]) {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpWidget(MaterialApp(
          home: Builder(
              builder: (context) => Text(
                  '${appPresentationPlatform.name}:${AppWindowClass.of(context).widthClass.name}'))));
      expect(
          find.text(
              '${appPresentationPlatform.name}:${width < 600 ? 'compact' : 'expanded'}'),
          findsOneWidget);
    }
  },
      variant: TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.windows
      }));
}
