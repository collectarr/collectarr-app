import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppWindowClass & WindowWidthClass Breakpoints', () {
    test('resolves compact width for phones (< 600 dp)', () {
      final window = AppWindowClass.fromSize(const Size(390, 844));
      expect(window.widthClass, WindowWidthClass.compact);
      expect(window.heightClass, WindowHeightClass.medium);
      expect(window.isCompact, isTrue);
      expect(window.isMobile, isTrue);
      expect(window.showBottomNav, isTrue);
      expect(window.showNavRail, isFalse);
      expect(window.showNavDrawer, isFalse);
    });

    test('resolves medium width for small tablets/foldables (600 - 839 dp)',
        () {
      final window = AppWindowClass.fromSize(const Size(768, 1024));
      expect(window.widthClass, WindowWidthClass.medium);
      expect(window.heightClass, WindowHeightClass.expanded);
      expect(window.isMedium, isTrue);
      expect(window.isTablet, isTrue);
      expect(window.isCompactOrMedium, isTrue);
      expect(window.showBottomNav, isFalse);
      expect(window.showNavRail, isTrue);
      expect(window.showNavDrawer, isFalse);
    });

    test('resolves expanded width for laptops/large tablets (840 - 1199 dp)',
        () {
      final window = AppWindowClass.fromSize(const Size(1024, 768));
      expect(window.widthClass, WindowWidthClass.expanded);
      expect(window.heightClass, WindowHeightClass.medium);
      expect(window.isExpanded, isTrue);
      expect(window.isDesktop, isTrue);
      expect(window.showBottomNav, isFalse);
      expect(window.showNavRail, isTrue);
      expect(window.showNavDrawer, isFalse);
    });

    test('resolves large width for standard desktops (1200 - 1599 dp)', () {
      final window = AppWindowClass.fromSize(const Size(1440, 900));
      expect(window.widthClass, WindowWidthClass.large);
      expect(window.heightClass, WindowHeightClass.expanded);
      expect(window.isLarge, isTrue);
      expect(window.isDesktop, isTrue);
      expect(window.showNavDrawer, isTrue);
      expect(window.showBottomNav, isFalse);
    });

    test('resolves extraLarge width for ultra-wide monitors (>= 1600 dp)', () {
      final window = AppWindowClass.fromSize(const Size(1920, 1080));
      expect(window.widthClass, WindowWidthClass.extraLarge);
      expect(window.heightClass, WindowHeightClass.expanded);
      expect(window.isExtraLarge, isTrue);
      expect(window.isLargeOrGreater, isTrue);
      expect(window.showNavDrawer, isTrue);
    });

    test('resolves compact height for landscape phones (< 480 dp)', () {
      final window = AppWindowClass.fromSize(const Size(844, 390));
      expect(window.heightClass, WindowHeightClass.compact);
      expect(window.heightClass.isCompact, isTrue);
    });
  });

  testWidgets('of responds to viewport changes', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final width in [400.0, 1400.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(MaterialApp(
          home: Builder(
              builder: (context) => Text(AppWindowClass.of(context).isCompact
                  ? 'Mobile'
                  : 'Desktop'))));
      expect(find.text(width == 400 ? 'Mobile' : 'Desktop'), findsOneWidget);
    }
  });
}
