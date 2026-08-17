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

    test('computes from BoxConstraints', () {
      final constraints = const BoxConstraints(maxWidth: 500, maxHeight: 800);
      final window = AppWindowClass.fromConstraints(constraints);
      expect(window.isCompact, isTrue);
      expect(window.heightClass, WindowHeightClass.medium);
    });
  });

  group('AdaptiveLayout Widget', () {
    testWidgets('provides correct windowClass to builder inside widget tree',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AppWindowClass? observedClass;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveLayout(
              builder: (context, windowClass) {
                observedClass = windowClass;
                return Text(windowClass.isCompact ? 'Mobile' : 'Desktop');
              },
            ),
          ),
        ),
      );

      expect(observedClass, isNotNull);
      expect(observedClass!.isCompact, isTrue);
      expect(find.text('Mobile'), findsOneWidget);

      // Resize to desktop
      tester.view.physicalSize = const Size(1400, 900);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveLayout(
              builder: (context, windowClass) {
                observedClass = windowClass;
                return Text(windowClass.isCompact ? 'Mobile' : 'Desktop');
              },
            ),
          ),
        ),
      );

      expect(observedClass!.isLarge, isTrue);
      expect(find.text('Desktop'), findsOneWidget);
    });
  });
}
