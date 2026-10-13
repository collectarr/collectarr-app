import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/sidebar.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_bucket_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';

void main() {
  testWidgets('group mode dropdown shows expandable folders sections',
      (tester) async {
    var selectedMode = 'music.release_year';
    var selectedPreset = LibraryFolderPreset.single(selectedMode);
    final pinnedPresets = <LibraryFolderPreset>[
      LibraryFolderPreset.single('music.artist'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 420,
              child: LibrarySidebar(
                type: const MusicRegistration(),
                accent: Colors.cyan,
                buckets: const [
                  LibraryBucket(title: 'All Albums', count: 12),
                ],
                groupMode: selectedMode,
                folderPreset: selectedPreset,
                selectedBucket: 'All Albums',
                onSelected: (_) {},
                onGroupModeChanged: (preset) {
                  selectedPreset = preset;
                  selectedMode = preset.primaryMode;
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
      find.text(genericGroupModeFolderSetLabel(
        selectedMode,
        const MusicRegistration(),
      )),
      findsOneWidget,
    );
    expect(find.text('Folder set'), findsNothing);
    expect(find.text('Current folder'), findsNothing);

    await tester.tap(find
        .text(genericGroupModeFolderSetLabel(
          selectedMode,
          const MusicRegistration(),
        ))
        .first);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('manageGroupFavoritesButton')),
        findsOneWidget);
    expect(find.byIcon(Icons.push_pin), findsNothing);
    expect(find.byIcon(Icons.push_pin_outlined), findsNothing);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Credits'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
    expect(find.text('Artist'), findsWidgets);
    expect(find.text('Format'), findsNothing);
    expect(find.text('Release Year'), findsWidgets);
    expect(find.text('Audience Rating'), findsNothing);
    expect(find.text('Artist'), findsWidgets);
    expect(find.text('Label'), findsWidgets);
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
                type: const MusicRegistration(),
                accent: Colors.cyan,
                buckets: const [
                  LibraryBucket(title: '[All Albums]', count: 12),
                  LibraryBucket(title: 'Action', count: 8),
                ],
                groupMode: 'music.genre',
                selectedBucket: '[All Albums]',
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

    expect(find.byTooltip('Manage genre'), findsOneWidget);

    await tester.tap(find.byTooltip('Manage genre'));
    await tester.pumpAndSettle();

    expect(manageTapped, isTrue);
  });

  testWidgets('series completion button filters sidebar buckets', (
    tester,
  ) async {
    var selectedScope = LibraryBucketCompletionScope.all;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SizedBox(
                  width: 320,
                  height: 420,
                  child: LibrarySidebar(
                    type: const MusicRegistration(),
                    accent: Colors.cyan,
                    buckets: const [
                      LibraryBucket(
                        title: 'Batman',
                        count: 10,
                        entryCount: 10,
                      ),
                      LibraryBucket(
                        title: 'Spawn',
                        count: 10,
                        entryCount: 6,
                      ),
                      LibraryBucket(title: 'Sandman', count: 5),
                    ],
                    groupMode: 'series',
                    selectedBucket: 'Batman',
                    onSelected: (_) {},
                    onGroupModeChanged: (_) {},
                    collectionStatusScope: LibraryCollectionStatusScope.all,
                    bucketCompletionScope: selectedScope,
                    onBucketCompletionScopeChanged: (value) {
                      setState(() => selectedScope = value);
                    },
                    onClearFilter: () {},
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Batman'), findsOneWidget);
    expect(find.text('Spawn'), findsOneWidget);
    expect(find.text('Sandman'), findsOneWidget);

    await tester.tap(find.byTooltip('Show all groups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show completed').last);
    await tester.pumpAndSettle();

    expect(find.text('Batman'), findsOneWidget);
    expect(find.text('Spawn'), findsNothing);
    expect(find.text('Sandman'), findsNothing);

    await tester.tap(find.byTooltip('Show completed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show not completed').last);
    await tester.pumpAndSettle();

    expect(find.text('Batman'), findsNothing);
    expect(find.text('Spawn'), findsOneWidget);
    expect(find.text('Sandman'), findsOneWidget);
  });
}
