import 'package:collectarr_app/features/library/generic/toolbar.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/secure_storage_mock.dart';

void main() {
  setUp(() {
    setUpSecureStorageMock();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('desktop toolbar alphabet row uses available width', (
    tester,
  ) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    tester.view.physicalSize = const Size(1800, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryToolbar(
              type: moviesLibraryConfig,
              searchController: searchController,
              viewState: moviesMediaAdapter.viewProfile.defaults(),
              adapter: moviesMediaAdapter,
              counts: const LibraryToolbarCounts(),
              onAdd: () {},
              onScan: () {},
              onSearchChanged: (_) {},
              onEditColumns: () {},
              onSortChanged: (_) {},
              onSidebarVisibilityChanged: (_) {},
              onViewModeChanged: (_) {},
              onDetailsLayoutChanged: (_) {},
              onCoverSizeChanged: (_) {},
              selectedBucket: null,
              onClearBucket: () {},
              onRefreshMetadata: () {},
              quickView: null,
              onQuickViewSelected: (_) {},
              availableLetters: const {'#', '0-9', 'A', 'C', 'M', 'Z'},
              selectedLetter: null,
              onLetterSelected: (_) {},
              hasActiveFilters: false,
              onClearFilters: () {},
              includeDesktopSecondaryBand: false,
            ),
          ),
        ),
      ),
    );

    final alphabetRow = find.byType(LibraryToolbarAlphabetRow);
    expect(alphabetRow, findsOneWidget);
    expect(tester.getSize(alphabetRow).width, greaterThan(380));

    expect(find.text('#'), findsOneWidget);
    expect(find.text('0-9'), findsOneWidget);
  });

  test('alpha jump bar groups symbol and numeric titles separately', () {
    expect(
      LibraryAlphaJumpBar.lettersFromTitles([
        'Batman',
        '7 Seeds',
        '#DRCL',
        '  20th Century Boys',
        '  !Hero',
      ]),
      {'B', '0-9', '#'},
    );

    expect(LibraryAlphaJumpBar.matchesLetter('7 Seeds', '0-9'), isTrue);
    expect(LibraryAlphaJumpBar.matchesLetter('#DRCL', '#'), isTrue);
    expect(LibraryAlphaJumpBar.matchesLetter('Batman', 'B'), isTrue);
    expect(LibraryAlphaJumpBar.matchesLetter('7 Seeds', '#'), isFalse);
  });

  testWidgets('view toolbar dropdowns use CLZ-style labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              LibraryViewModeDropdown(
                viewMode: LibraryViewMode.card,
                onChanged: (_) {},
              ),
              const SizedBox(width: 8),
              LibraryDetailsLayoutDropdown(
                detailsLayout: LibraryDetailsLayout.right,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('View'), findsOneWidget);
    expect(find.text('Vertical Cards'), findsOneWidget);
    expect(find.text('Layout'), findsOneWidget);
    expect(find.text('Vertical Split'), findsOneWidget);
  });
}
