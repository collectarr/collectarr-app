import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('group mode dropdown exposes favorites and folders sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeDropdownMenu(
            type: movieKindModule,
            selectedPreset: LibraryFolderPreset.single(
              'movie.director',
            ),
            availableModes: libraryGroupModesForType(movieKindModule),
            initialPinnedPresets: [
              LibraryFolderPreset.single('movie.director'),
            ],
            sidebarVisible: true,
            hasSidebarVisibilityToggle: true,
            triggerLabel: 'Director',
          ),
        ),
      ),
    );

    expect(find.text('No folders'), findsOneWidget);
    expect(find.text('Show folders'), findsNothing);
    expect(find.byKey(const ValueKey('manageGroupFavoritesButton')),
        findsOneWidget);
    expect(find.byIcon(Icons.push_pin), findsNothing);
    expect(find.byIcon(Icons.push_pin_outlined), findsNothing);
    expect(find.text('Manage Favorites'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Cast & Crew'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Director'), findsWidgets);
    expect(find.text('Studios'), findsNothing);

    final selectedRow = tester.widget<LibraryWorkspaceMenuRow>(
      find.byKey(const ValueKey('groupModeItemRow_movie.director')),
    );
    expect(selectedRow.backgroundColor, isNot(Colors.transparent));

    final mainHeader = find.widgetWithText(InkWell, 'Main');
    await tester.ensureVisible(mainHeader);
    await tester.tap(mainHeader);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('groupModeSectionLevelBar_Main')),
      findsOneWidget,
    );
    expect(find.text('Studios'), findsOneWidget);
  });

  testWidgets('hidden grouping menu does not offer a show folders toggle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeDropdownMenu(
            type: movieKindModule,
            selectedPreset: null,
            availableModes: libraryGroupModesForType(movieKindModule),
            initialPinnedPresets: const [],
            sidebarVisible: false,
            hasSidebarVisibilityToggle: true,
          ),
        ),
      ),
    );

    expect(find.text('No folders'), findsNothing);
    expect(find.text('Show folders'), findsNothing);
    expect(find.text('Cast & Crew'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('manage favorites button opens a dedicated dialog', (
    tester,
  ) async {
    List<LibraryFolderPreset>? savedPresets;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeMenuButton(
            type: movieKindModule,
            folderPreset: LibraryFolderPreset.single(
              'movie.director',
            ),
            accent: Colors.cyan,
            icon: Icons.account_tree_outlined,
            onChanged: (_) {},
            pinnedFolderPresets: [
              LibraryFolderPreset.single('movie.director'),
            ],
            onPinnedPresetsChanged: (value) => savedPresets = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Group by'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('manageGroupFavoritesButton')));
    await tester.pumpAndSettle();

    expect(find.text('Manage Folder Favorites'), findsOneWidget);
    expect(find.text('Director'), findsWidgets);

    await tester
        .tap(find.byKey(const ValueKey('folderFavoritesManagerSaveButton')));
    await tester.pumpAndSettle();

    expect(savedPresets, isNotNull);
    expect(
      savedPresets,
      [LibraryFolderPreset.single('movie.director')],
    );
  });

  testWidgets('no folders clears the active bucket before hiding folders', (
    tester,
  ) async {
    var clearedBucket = false;
    var sidebarVisible = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeMenuButton(
            type: movieKindModule,
            folderPreset: LibraryFolderPreset.single(
              'movie.director',
            ),
            accent: Colors.cyan,
            icon: Icons.account_tree_outlined,
            onChanged: (_) {},
            sidebarVisible: sidebarVisible,
            onSidebarVisibilityChanged: (value) => sidebarVisible = value,
            onClearBucket: () => clearedBucket = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Group by'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No folders'));
    await tester.pumpAndSettle();

    expect(clearedBucket, isTrue);
    expect(sidebarVisible, isFalse);
  });

  testWidgets('add favorite button opens the editor pane', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeMenuButton(
            type: movieKindModule,
            folderPreset: LibraryFolderPreset.single(
              'movie.director',
            ),
            accent: Colors.cyan,
            icon: Icons.account_tree_outlined,
            onChanged: (_) {},
            pinnedFolderPresets: const [],
            onPinnedPresetsChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Group by'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('manageGroupFavoritesButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('folderFavoritesAddButton')));
    await tester.pumpAndSettle();

    expect(find.text('Select one or more fields'), findsWidgets);
    expect(find.byKey(const ValueKey('folderFavoritesDraftSaveButton')),
        findsOneWidget);
  });

  testWidgets('group mode button shows the configured folder set label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeMenuButton(
            type: movieKindModule,
            folderPreset: LibraryFolderPreset(
              modes: ['movie.director', 'movie.publisher'],
            ),
            accent: Colors.cyan,
            icon: Icons.account_tree_outlined,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Director / Studios'), findsOneWidget);
  });

  testWidgets('group mode button opens menu on hover', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeMenuButton(
            type: movieKindModule,
            folderPreset: LibraryFolderPreset.single(
              'movie.director',
            ),
            accent: Colors.cyan,
            icon: Icons.account_tree_outlined,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Group by'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('groupModeSectionLevelBar_Cast & Crew')),
        findsOneWidget);
  });

  testWidgets(
      'group mode button closes menu after pointer leaves trigger and menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: LibraryGroupModeMenuButton(
              type: movieKindModule,
              folderPreset: LibraryFolderPreset.single(
                'movie.director',
              ),
              accent: Colors.cyan,
              icon: Icons.account_tree_outlined,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Group by'));
    await tester.pumpAndSettle();

    expect(find.text('Cast & Crew'), findsOneWidget);

    await tester.tapAt(const Offset(700, 500));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('groupModeMenuCurrentLabel')), findsNothing);
  });

  testWidgets('comic group mode dropdown uses CLZ-like section taxonomy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeDropdownMenu(
            type: comicKindModule,
            selectedPreset: LibraryFolderPreset.single('comic.publisher'),
            availableModes: libraryGroupModesForType(comicKindModule),
            initialPinnedPresets: [
              LibraryFolderPreset.single('comic.series'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Publisher'), findsWidgets);
    expect(find.text('Series'), findsWidgets);

    final personalHeader = find.widgetWithText(InkWell, 'Personal');
    await tester.ensureVisible(personalHeader);
    await tester.tap(personalHeader);
    await tester.pumpAndSettle();

    expect(find.text('Locations'), findsOneWidget);
  });
}
