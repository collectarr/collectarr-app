import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
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
            type: moviesLibraryConfig,
            selectedPreset: LibraryFolderPreset.single(
              LibraryGroupMode.releaseYear,
            ),
            availableModes: libraryGroupModesForType(moviesLibraryConfig),
            initialPinnedPresets: [
              LibraryFolderPreset.single(LibraryGroupMode.director),
            ],
            sidebarVisible: true,
            hasSidebarVisibilityToggle: true,
          ),
        ),
      ),
    );

    expect(find.text('No folders'), findsOneWidget);
    expect(find.text('Show folders'), findsNothing);
    expect(find.text('Manage Favorites'), findsOneWidget);
    expect(find.byIcon(Icons.push_pin), findsNothing);
    expect(find.byIcon(Icons.push_pin_outlined), findsNothing);
    expect(find.text('Favorites'), findsWidgets);
    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Edition'), findsOneWidget);
    expect(find.text('Cast & Crew'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Director'), findsWidgets);
    expect(find.text('Format'), findsNothing);
    expect(find.text('Release Year'), findsWidgets);
    expect(find.text('Audience Rating'), findsOneWidget);
    expect(find.text('Movie / TV Series'), findsOneWidget);
    expect(find.text('Studios'), findsOneWidget);
    expect(find.byKey(const ValueKey('groupModeSectionBar_Main')), findsNothing);
    expect(
      find.byKey(const ValueKey('groupModeSectionLevelBar_Main')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('groupModeItemBar_releaseYear')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('groupModeSectionBar_Cast & Crew')),
      findsNothing,
    );

    final selectedRow = tester.widget<LibraryWorkspaceMenuRow>(
      find.byKey(const ValueKey('groupModeItemRow_releaseYear')),
    );
    expect(selectedRow.backgroundColor, Colors.transparent);

    final editionHeader = find.widgetWithText(InkWell, 'Edition');
    await tester.ensureVisible(editionHeader);
    await tester.tap(editionHeader);
    await tester.pumpAndSettle();

    expect(find.text('Format'), findsOneWidget);
    expect(find.text('Audio Tracks'), findsOneWidget);
    expect(find.text('Edition Release Date'), findsOneWidget);

    final mainHeader = find.widgetWithText(InkWell, 'Main');
    await tester.ensureVisible(mainHeader);
    await tester.tap(mainHeader);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('groupModeSectionBar_Main')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('groupModeSectionLevelBar_Main')),
      findsNothing,
    );
  });

  testWidgets('hidden grouping menu does not offer a show folders toggle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeDropdownMenu(
            type: moviesLibraryConfig,
            selectedPreset: null,
            availableModes: libraryGroupModesForType(moviesLibraryConfig),
            initialPinnedPresets: const [],
            sidebarVisible: false,
            hasSidebarVisibilityToggle: true,
          ),
        ),
      ),
    );

    expect(find.text('No folders'), findsNothing);
    expect(find.text('Show folders'), findsNothing);
    expect(find.text('Main'), findsOneWidget);
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
            type: moviesLibraryConfig,
            folderPreset: LibraryFolderPreset.single(
              LibraryGroupMode.releaseYear,
            ),
            accent: Colors.cyan,
            icon: Icons.account_tree_outlined,
            onChanged: (_) {},
            pinnedFolderPresets: [
              LibraryFolderPreset.single(LibraryGroupMode.director),
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

    await tester.tap(find.byKey(const ValueKey('folderFavoritesManagerSaveButton')));
    await tester.pumpAndSettle();

    expect(savedPresets, isNotNull);
    expect(
      savedPresets,
      [LibraryFolderPreset.single(LibraryGroupMode.director)],
    );
  });

  testWidgets('add favorite button opens the editor pane', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeMenuButton(
            type: moviesLibraryConfig,
            folderPreset: LibraryFolderPreset.single(
              LibraryGroupMode.releaseYear,
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
    expect(find.byKey(const ValueKey('folderFavoritesDraftSaveButton')), findsOneWidget);
  });

  testWidgets('group mode button shows the configured folder set label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeMenuButton(
            type: moviesLibraryConfig,
            folderPreset: LibraryFolderPreset(
              modes: [LibraryGroupMode.ageRating, LibraryGroupMode.country],
            ),
            accent: Colors.cyan,
            icon: Icons.account_tree_outlined,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Age / Country'), findsOneWidget);
  });
}