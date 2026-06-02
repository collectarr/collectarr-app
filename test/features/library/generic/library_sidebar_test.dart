import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/sidebar.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('group mode dropdown shows expandable folders sections',
      (tester) async {
    var selectedMode = LibraryGroupMode.releaseYear;
    var selectedPreset = LibraryFolderPreset.single(selectedMode);
    final pinnedPresets = <LibraryFolderPreset>[
      LibraryFolderPreset.single(LibraryGroupMode.director),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 420,
              child: LibrarySidebar(
                type: moviesLibraryConfig,
                accent: Colors.cyan,
                buckets: const [
                  LibrarySeriesBucket(title: 'All Movies', count: 12),
                ],
                groupMode: selectedMode,
                folderPreset: selectedPreset,
                selectedBucket: 'All Movies',
                onSelected: (_) {},
                onGroupModeChanged: (value) {
                  selectedPreset = LibraryFolderPreset.single(value);
                  selectedMode = value;
                },
                collectionStatusScope: LibraryCollectionStatusScope.all,
                onClearFilter: () {},
                pinnedFolderPresets: pinnedPresets,
                onPinnedFolderPresetsChanged: (presets) {
                  pinnedPresets
                    ..clear()
                    ..addAll(presets);
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text(genericGroupModeFolderSetLabel(selectedMode, moviesLibraryConfig)),
      findsOneWidget,
    );
    expect(find.text('Folder set'), findsNothing);
    expect(find.text('Current folder'), findsNothing);

    await tester.tap(find.text(genericGroupModeFolderSetLabel(selectedMode, moviesLibraryConfig)).first);
    await tester.pumpAndSettle();

    expect(find.text('Manage Favorites'), findsOneWidget);
  expect(find.byIcon(Icons.push_pin), findsNothing);
  expect(find.byIcon(Icons.push_pin_outlined), findsNothing);
    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('Favorites'), findsWidgets);
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

    final editionHeader = find.widgetWithText(InkWell, 'Edition');
    await tester.ensureVisible(editionHeader);
    await tester.tap(editionHeader);
    await tester.pumpAndSettle();

    expect(find.text('Format'), findsOneWidget);
    expect(find.text('Audio Tracks'), findsOneWidget);
    expect(find.text('Edition Release Date'), findsOneWidget);

    await tester.tap(editionHeader);
    await tester.pumpAndSettle();

    expect(find.text('Format'), findsNothing);
  });

  testWidgets('sidebar shows a manage button for editable group buckets', (
    tester,
  ) async {
    var manageTapped = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 420,
              child: LibrarySidebar(
                type: moviesLibraryConfig,
                accent: Colors.cyan,
                buckets: const [
                  LibrarySeriesBucket(title: '[All Movies]', count: 12),
                  LibrarySeriesBucket(title: 'Action', count: 8),
                ],
                groupMode: LibraryGroupMode.genre,
                selectedBucket: '[All Movies]',
                onSelected: (_) {},
                onGroupModeChanged: (_) {},
                collectionStatusScope: LibraryCollectionStatusScope.all,
                onClearFilter: () {},
                onManageBuckets: () => manageTapped = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Manage genres'), findsOneWidget);

    await tester.tap(find.byTooltip('Manage genres'));
    await tester.pumpAndSettle();

    expect(manageTapped, isTrue);
  });
}