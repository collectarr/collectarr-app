import 'package:collectarr_app/ui/error_banner.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:collectarr_app/ui/theme/library_theme.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/secure_storage_mock.dart';
import '../helpers/test_constants.dart';

/// Golden file comparator that tolerates small pixel differences caused by
/// cross-platform font rendering (e.g. Windows vs Linux CI).
class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(super.testFile);

  /// Default tolerance for cross-platform text/icon antialiasing drift.
  static const double _kDefaultTolerance = 0.005;

  /// Known Linux-vs-Windows drift hotspots for these specific snapshots.
  static const Map<String, double> _kPerGoldenTolerance = {
    'goldens/status_icons_all.png': 0.015,
    'goldens/tag_pick_list_field.png': 0.015,
  };

  double _toleranceFor(Uri golden) {
    final path = golden.path.replaceAll('\\', '/');
    for (final entry in _kPerGoldenTolerance.entries) {
      if (path.endsWith(entry.key)) {
        return entry.value;
      }
    }
    return _kDefaultTolerance;
  }

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    final tolerance = _toleranceFor(golden);
    if (!result.passed && result.diffPercent <= tolerance) {
      debugPrint(
        'Golden "$golden": ${result.diffPercent.toStringAsFixed(2)}% diff '
        '(within ${(tolerance * 100).toStringAsFixed(1)}% tolerance)',
      );
      return true;
    }
    return result.passed;
  }
}

void main() {
  setUpAll(() {
    debugDisableShadows = true;
    final basedir = (goldenFileComparator as LocalFileComparator).basedir;
    // LocalFileComparator expects a file URI and derives basedir via dirname;
    // pass a synthetic file URI so basedir resolves to the test directory.
    goldenFileComparator = _TolerantGoldenFileComparator(
      basedir.resolve('golden_widget_test.dart'),
    );
  });

  tearDownAll(() {
    debugDisableShadows = false;
  });

  setUp(setUpSecureStorageMock);

  Widget wrapWidget(Widget child, {Size size = const Size(400, 300)}) {
    return MaterialApp(
      theme: buildLibraryTheme().copyWith(platform: TargetPlatform.android),
      home: Scaffold(body: Center(child: child)),
    );
  }

  void setView(WidgetTester tester, {Size size = const Size(400, 300)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('AppErrorCard golden', () {
    testWidgets('renders with message only', (tester) async {
      setView(tester);
      await tester.pumpWidget(wrapWidget(
        const AppErrorCard(message: 'Something went wrong'),
      ));
      await pumpUntilSettled(tester);

      await expectLater(
        find.byType(AppErrorCard),
        matchesGoldenFile('goldens/error_card_message_only.png'),
      );
    });

    testWidgets('renders with retry button', (tester) async {
      setView(tester);
      await tester.pumpWidget(wrapWidget(
        AppErrorCard(message: 'Connection lost', onRetry: () {}),
      ));
      await pumpUntilSettled(tester);

      await expectLater(
        find.byType(AppErrorCard),
        matchesGoldenFile('goldens/error_card_with_retry.png'),
      );
    });
  });

  group('AppErrorBanner golden', () {
    testWidgets('renders inline error', (tester) async {
      setView(tester, size: const Size(400, 100));
      await tester.pumpWidget(wrapWidget(
        const AppErrorBanner('Failed to load metadata'),
        size: const Size(400, 100),
      ));
      await pumpUntilSettled(tester);

      await expectLater(
        find.byType(AppErrorBanner),
        matchesGoldenFile('goldens/error_banner.png'),
      );
    });
  });

  group('LibraryCoverBadges golden', () {
    testWidgets('renders all badges', (tester) async {
      setView(tester, size: const Size(500, 80));
      await tester.pumpWidget(wrapWidget(
        const LibraryCoverBadges(
          isOwned: true,
          isTracked: true,
          isWishlisted: true,
          hasMissingCover: true,
          hasMissingMetadata: true,
          keyLabel: 'First appearance',
          slabLabel: 'CGC 9.8',
          notesLabel: 'Signed',
        ),
        size: const Size(500, 80),
      ));
      await pumpUntilSettled(tester);

      await expectLater(
        find.byType(LibraryCoverBadges),
        matchesGoldenFile('goldens/cover_badges_all.png'),
      );
    });

    testWidgets('renders owned only', (tester) async {
      setView(tester, size: const Size(200, 60));
      await tester.pumpWidget(wrapWidget(
        const LibraryCoverBadges(
          isOwned: true,
          isTracked: false,
          isWishlisted: false,
        ),
        size: const Size(200, 60),
      ));
      await pumpUntilSettled(tester);

      await expectLater(
        find.byType(LibraryCoverBadges),
        matchesGoldenFile('goldens/cover_badges_owned.png'),
      );
    });
  });

  group('LibraryItemStatusIcons golden', () {
    testWidgets('renders all status icons', (tester) async {
      setView(tester, size: const Size(300, 60));
      await tester.pumpWidget(wrapWidget(
        const LibraryItemStatusIcons(
          isOwned: true,
          isTracked: true,
          isWishlisted: true,
          hasMissingCover: true,
          hasMissingMetadata: true,
          hasKeyMarker: true,
          hasSlabMarker: true,
          hasNotesMarker: true,
        ),
        size: const Size(300, 60),
      ));
      await pumpUntilSettled(tester);

      await expectLater(
        find.byType(LibraryItemStatusIcons),
        matchesGoldenFile('goldens/status_icons_all.png'),
      );
    });

    testWidgets('renders unowned no flags', (tester) async {
      setView(tester, size: const Size(200, 60));
      await tester.pumpWidget(wrapWidget(
        const LibraryItemStatusIcons(
          isOwned: false,
          isTracked: false,
          isWishlisted: false,
        ),
        size: const Size(200, 60),
      ));
      await pumpUntilSettled(tester);

      await expectLater(
        find.byType(LibraryItemStatusIcons),
        matchesGoldenFile('goldens/status_icons_unowned.png'),
      );
    });
  });

  group('TagPickListField golden', () {
    testWidgets('renders with quick tags', (tester) async {
      setView(tester, size: const Size(400, 250));
      final controller = TextEditingController(text: 'Action');
      addTearDown(controller.dispose);

      await tester.pumpWidget(wrapWidget(
        TagPickListField(
          controller: controller,
          options: const ['Action', 'Horror', 'Sci-Fi', 'Fantasy'],
          label: 'Genres',
          hint: 'Enter genres',
        ),
        size: const Size(400, 250),
      ));
      await pumpUntilSettled(tester);

      await expectLater(
        find.byType(TagPickListField),
        matchesGoldenFile('goldens/tag_pick_list_field.png'),
      );
    });
  });
}
