import 'package:collectarr_app/features/library/generic/library_group_mode_menu.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_workspace_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';

void main() {
  testWidgets('folder favorite actions inherit the kind accent',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => showLibraryFolderFavoritesDialog(
                        context: context,
                        type: const MusicRegistration(),
                        availableModes: libraryGroupModesForType(
                            const MusicRegistration())),
                    child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Save'));
    expect(
        appPalette(context).accent, const MusicRegistration().identity.accent);
    expect(Theme.of(context).colorScheme.primary, appPalette(context).accent);
    expect(
        appPalette(context).selection,
        Color.alphaBlend(appPalette(context).accent.withValues(alpha: 0.22),
            appPalette(context).panel));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
  testWidgets('group mode dropdown exposes favorites and folders sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeDropdownMenu(
            type: const MusicRegistration(),
            selectedPreset: LibraryFolderPreset.single(
              'music.artist',
            ),
            availableModes: libraryGroupModesForType(const MusicRegistration()),
            initialPinnedPresets: [
              LibraryFolderPreset.single('music.artist'),
            ],
            sidebarVisible: true,
            hasSidebarVisibilityToggle: true,
            triggerLabel: 'Artist',
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
    expect(find.text('Credits'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Artist'), findsWidgets);
    expect(find.text('Labels'), findsNothing);

    final selectedRow = tester.widget<LibraryWorkspaceMenuRow>(
      find.byKey(const ValueKey('groupModeItemRow_music.artist')),
    );
    expect(selectedRow.backgroundColor, isNot(Colors.transparent));

    final mainHeader = find.widgetWithText(InkWell, 'Main');
    await tester.ensureVisible(mainHeader);
    await tester.tap(mainHeader);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('groupModeItemRow_music.artist')),
        findsNothing);
  });

  testWidgets('hidden grouping menu does not offer a show folders toggle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeDropdownMenu(
            type: const MusicRegistration(),
            selectedPreset: null,
            availableModes: libraryGroupModesForType(const MusicRegistration()),
            initialPinnedPresets: const [],
            sidebarVisible: false,
            hasSidebarVisibilityToggle: true,
          ),
        ),
      ),
    );

    expect(find.text('No folders'), findsNothing);
    expect(find.text('Show folders'), findsNothing);
    expect(find.text('Credits'), findsOneWidget);
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
            type: const MusicRegistration(),
            folderPreset: LibraryFolderPreset.single(
              'music.artist',
            ),
            accent: Colors.cyan,
            icon: Icons.account_tree_outlined,
            onChanged: (_) {},
            pinnedFolderPresets: [
              LibraryFolderPreset.single('music.artist'),
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
    expect(find.text('Artist'), findsWidgets);

    await tester
        .tap(find.byKey(const ValueKey('folderFavoritesManagerSaveButton')));
    await tester.pumpAndSettle();

    expect(savedPresets, isNotNull);
    expect(
      savedPresets,
      [LibraryFolderPreset.single('music.artist')],
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
            type: const MusicRegistration(),
            folderPreset: LibraryFolderPreset.single(
              'music.artist',
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
            type: const MusicRegistration(),
            folderPreset: LibraryFolderPreset.single(
              'music.artist',
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
            type: const MusicRegistration(),
            folderPreset: LibraryFolderPreset(
              modes: ['music.artist', 'music.publisher'],
            ),
            accent: Colors.cyan,
            icon: Icons.account_tree_outlined,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Artist / Label'), findsOneWidget);
  });

  testWidgets('group mode button stays quiet when its slot is too narrow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 20,
            child: LibraryGroupModeMenuButton(
              type: const MusicRegistration(),
              folderPreset: LibraryFolderPreset.single('music.artist'),
              accent: Colors.cyan,
              icon: Icons.account_tree_outlined,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Artist'), findsNothing);
  });

  testWidgets('group mode button opens menu on hover', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeMenuButton(
            type: const MusicRegistration(),
            folderPreset: LibraryFolderPreset.single(
              'music.artist',
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

    expect(find.text('Credits'), findsOneWidget);
    expect(find.text('Manage Favorites'), findsOneWidget);
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
              type: const MusicRegistration(),
              folderPreset: LibraryFolderPreset.single(
                'music.artist',
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

    expect(find.text('Credits'), findsOneWidget);

    await tester.tapAt(const Offset(700, 500));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('groupModeMenuCurrentLabel')), findsNothing);
  });

  testWidgets('Music grouping offers catalog, credits and personal sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LibraryGroupModeDropdownMenu(
            type: const MusicRegistration(),
            selectedPreset: LibraryFolderPreset.single('music.publisher'),
            availableModes: libraryGroupModesForType(const MusicRegistration()),
            initialPinnedPresets: [
              LibraryFolderPreset.single('music.artist'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Label'), findsWidgets);
    expect(find.text('Credits'), findsOneWidget);

    expect(find.text('Locations'), findsNothing);
  });
}
