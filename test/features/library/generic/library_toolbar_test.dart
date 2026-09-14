import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/generic/toolbar.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_view_controls.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_alpha_jump_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';

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
              type: const MovieRegistration(),
              searchController: searchController,
              viewState: movieKindViewProfile.defaults(),
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

  testWidgets('alphabet row selected button uses library accent', (
    tester,
  ) async {
    const selectedLetter = 'A';
    final accent = movieKindIdentity.accent;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryToolbarAlphabetRow(
            letters: const {'A', 'B'},
            selectedLetter: selectedLetter,
            accent: accent,
            onLetterSelected: (_) {},
          ),
        ),
      ),
    );

    final selectedText = tester.widget<Text>(find.text(selectedLetter));
    expect(selectedText.style?.color, accent);
  });

  testWidgets('alphabet buttons have a slightly wider touch target', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryToolbarAlphabetRow(
            letters: const {'A', 'B'},
            selectedLetter: null,
            accent: movieKindIdentity.accent,
            onLetterSelected: (_) {},
          ),
        ),
      ),
    );

    final aButton =
        find.ancestor(of: find.text('A'), matching: find.byType(InkWell)).first;
    expect(tester.getSize(aButton).width, greaterThanOrEqualTo(28));
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

  testWidgets('toolbar gates scan cover action by type capability',
      (tester) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    tester.view.physicalSize = const Size(1800, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> expectScanCover({
      required LibraryKindRegistration type,
      required LibraryWorkspaceViewState viewState,
      required bool expected,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LibraryToolbar(
                type: type,
                searchController: searchController,
                viewState: viewState,
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
                hasActiveFilters: false,
                onClearFilters: () {},
                onScanCover: () {},
              ),
            ),
          ),
        ),
      );

      final filtering = tester.widget<LibraryDesktopFilteringToolbar>(
        find.byType(LibraryDesktopFilteringToolbar),
      );
      expect(filtering.onScanCover != null, expected);
    }

    await expectScanCover(
      type: const MovieRegistration(),
      viewState: movieKindViewProfile.defaults(),
      expected: true,
    );
    await expectScanCover(
      type: const BookRegistration(),
      viewState: bookKindViewProfile.defaults(),
      expected: true,
    );
    await expectScanCover(
      type: const GameRegistration(),
      viewState: gameKindViewProfile.defaults(),
      expected: true,
    );
    await expectScanCover(
      type: const BoardgameRegistration(),
      viewState: boardGameKindViewProfile.defaults(),
      expected: true,
    );
    await expectScanCover(
      type: const ComicRegistration(),
      viewState: comicKindViewProfile.defaults(),
      expected: true,
    );
  });

  testWidgets('toolbar gates reading queue action by type capability', (
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
              type: const MovieRegistration(),
              searchController: searchController,
              viewState: movieKindViewProfile.defaults(),
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
              hasActiveFilters: false,
              onClearFilters: () {},
              onReadingQueue: () {},
            ),
          ),
        ),
      ),
    );

    final movieSecondary = tester.widget<LibraryDesktopSecondaryToolbar>(
      find.byType(LibraryDesktopSecondaryToolbar),
    );
    expect(movieSecondary.onReadingQueue, isNull);
    expect(movieSecondary.showBottomBorder, isFalse);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryToolbar(
              type: const BookRegistration(),
              searchController: searchController,
              viewState: bookKindViewProfile.defaults(),
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
              hasActiveFilters: false,
              onClearFilters: () {},
              onReadingQueue: () {},
            ),
          ),
        ),
      ),
    );

    final booksSecondary = tester.widget<LibraryDesktopSecondaryToolbar>(
      find.byType(LibraryDesktopSecondaryToolbar),
    );
    expect(booksSecondary.onReadingQueue, isNotNull);
  });

  testWidgets('toolbar gates reassign-index action by type capability', (
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
              type: const MovieRegistration(),
              searchController: searchController,
              viewState: movieKindViewProfile.defaults(),
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
              hasActiveFilters: false,
              onClearFilters: () {},
              onReassignIndex: () {},
            ),
          ),
        ),
      ),
    );

    final movieSecondary = tester.widget<LibraryDesktopSecondaryToolbar>(
      find.byType(LibraryDesktopSecondaryToolbar),
    );
    expect(movieSecondary.onReassignIndex, isNull);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryToolbar(
              type: const ComicRegistration(),
              searchController: searchController,
              viewState: comicKindViewProfile.defaults(),
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
              hasActiveFilters: false,
              onClearFilters: () {},
              onReassignIndex: () {},
            ),
          ),
        ),
      ),
    );

    final comicsSecondary = tester.widget<LibraryDesktopSecondaryToolbar>(
      find.byType(LibraryDesktopSecondaryToolbar),
    );
    expect(comicsSecondary.onReassignIndex, isNotNull);
  });

  testWidgets('toolbar can hide desktop secondary band explicitly',
      (tester) async {
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
              type: const ComicRegistration(),
              searchController: searchController,
              viewState: comicKindViewProfile.defaults(),
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
              hasActiveFilters: false,
              onClearFilters: () {},
              includeDesktopSecondaryBand: false,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(LibraryDesktopSecondaryToolbar), findsNothing);
  });

  testWidgets(
      'toolbar forwards folder rail controls to desktop secondary toolbar',
      (tester) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    tester.view.physicalSize = const Size(1800, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final folderPreset = LibraryFolderPreset.single('series');
    final pinnedPresets = <LibraryFolderPreset>[
      LibraryFolderPreset.single('series'),
      LibraryFolderPreset.single('title'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryToolbar(
              type: const ComicRegistration(),
              searchController: searchController,
              viewState: comicKindViewProfile.defaults(),
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
              hasActiveFilters: false,
              onClearFilters: () {},
              groupMode: 'series',
              folderPreset: folderPreset,
              pinnedFolderPresets: pinnedPresets,
              onPinnedFolderPresetsChanged: (_) {},
              onGroupModeChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final secondary = tester.widget<LibraryDesktopSecondaryToolbar>(
      find.byType(LibraryDesktopSecondaryToolbar),
    );
    expect(secondary.groupMode, 'series');
    expect(secondary.folderPreset, folderPreset);
    expect(secondary.pinnedFolderPresets, pinnedPresets);
    expect(secondary.onGroupModeChanged, isNotNull);
    expect(secondary.onPinnedFolderPresetsChanged, isNotNull);
  });

  testWidgets(
      'compact selection band drops bottom border when chrome row follows',
      (tester) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: LibraryToolbar(
              type: const ComicRegistration(),
              searchController: searchController,
              viewState: comicKindViewProfile.defaults(),
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
              hasActiveFilters: false,
              onClearFilters: () {},
              onCollectionStatusScopeChanged: (_) {},
              selectionCallbacks: (
                onClearSelection: () {},
                onSelectAll: () {},
                onBulkEdit: () {},
                onPrintToPdf: () {},
                onExportCsvTxt: () {},
                onBulkDuplicate: () {},
                onBulkLoan: () {},
                onTransferFieldData: () {},
                onBulkUpdateValues: null,
                onBulkUpdateKeyInfo: null,
                onBulkMoveToOwned: null,
                onBulkMoveToWishlist: null,
                onBulkRemove: () {},
                onBulkRefreshMetadata: () {},
              ),
              selectedCount: 2,
              totalSelectableCount: 5,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(LibraryToolbarChromeRow), findsOneWidget);
    final selectionBand = tester.widget<LibrarySelectionToolbarBand>(
      find.byType(LibrarySelectionToolbarBand),
    );
    expect(selectionBand.showBottomBorder, isFalse);
  });

  testWidgets('toolbar capability gates stay consistent across all kinds',
      (tester) async {
    final searchController = TextEditingController();
    addTearDown(searchController.dispose);
    tester.view.physicalSize = const Size(1800, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final type in defaultLibraryKindRegistry.allKinds) {
      final runtime = type;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: LibraryToolbar(
                type: type,
                searchController: searchController,
                viewState: libraryViewProfileForKind(runtime.kind).defaults(),
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
                hasActiveFilters: false,
                onClearFilters: () {},
                onScanCover: () {},
                onReadingQueue: () {},
                onReassignIndex: () {},
              ),
            ),
          ),
        ),
      );

      final filtering = tester.widget<LibraryDesktopFilteringToolbar>(
        find.byType(LibraryDesktopFilteringToolbar),
      );
      final secondary = tester.widget<LibraryDesktopSecondaryToolbar>(
        find.byType(LibraryDesktopSecondaryToolbar),
      );

      expect(
        filtering.onScanCover,
        libraryAddForKind(type.kind).chrome.canScanCover ? isNotNull : isNull,
        reason: 'scan-cover gate mismatch for ${type.kind.apiValue}',
      );
      expect(
        secondary.onReadingQueue,
        type.toolbarActionAvailability
                .allows(LibraryToolbarActionId.readingQueue)
            ? isNotNull
            : isNull,
        reason: 'reading-queue gate mismatch for ${type.kind.apiValue}',
      );
      expect(
        secondary.onReassignIndex,
        type.toolbarActionAvailability
                .allows(LibraryToolbarActionId.reassignIndex)
            ? isNotNull
            : isNull,
        reason: 'reassign-index gate mismatch for ${type.kind.apiValue}',
      );
    }
  });

  test('comic kind exposes a contributor-owned missing issues toolbar action', () {
    final action = comicKindToolbar.actions
        .firstWhere((a) => a.id == 'comic.missing_issues');
    expect(action.id, 'comic.missing_issues');
    expect(action.label, 'Missing issues report...');
    expect(action.icon, Icons.find_in_page_outlined);

    final context = LibraryToolbarActionContext(
      buildContext: _FakeBuildContext(),
      type: const ComicRegistration(),
      projection: null,
      onJumpToNumberSubmitted: (_) {},
      onMissingSequenceReport: (_) {},
    );

    expect(action.isVisible(context), isFalse);
    expect(action.isEnabled(context), isFalse);
  });
}

class _FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
