import 'package:collectarr_app/ui/error_banner.dart';
import 'package:collectarr_app/ui/error_card.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:collectarr_app/ui/theme/library_theme.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/secure_storage_mock.dart';
import '../helpers/test_constants.dart';

void main() {
  setUp(setUpSecureStorageMock);

  Widget _wrap(Widget child, {Size size = const Size(400, 300)}) {
    return MaterialApp(
      theme: buildLibraryTheme(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  void _setView(WidgetTester tester, {Size size = const Size(400, 300)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = kDesktopTestDPR;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('AppErrorCard golden', () {
    testWidgets('renders with message only', (tester) async {
      _setView(tester);
      await tester.pumpWidget(_wrap(
        const AppErrorCard(message: 'Something went wrong'),
      ));
      await pumpUntilSettled(tester);

      await expectLater(
        find.byType(AppErrorCard),
        matchesGoldenFile('goldens/error_card_message_only.png'),
      );
    });

    testWidgets('renders with retry button', (tester) async {
      _setView(tester);
      await tester.pumpWidget(_wrap(
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
      _setView(tester, size: const Size(400, 100));
      await tester.pumpWidget(_wrap(
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
      _setView(tester, size: const Size(500, 80));
      await tester.pumpWidget(_wrap(
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
      _setView(tester, size: const Size(200, 60));
      await tester.pumpWidget(_wrap(
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
      _setView(tester, size: const Size(300, 60));
      await tester.pumpWidget(_wrap(
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
      _setView(tester, size: const Size(200, 60));
      await tester.pumpWidget(_wrap(
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
      _setView(tester, size: const Size(400, 250));
      final controller = TextEditingController(text: 'Action');
      addTearDown(controller.dispose);

      await tester.pumpWidget(_wrap(
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
