import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('music filter dialog uses artist and label labels',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showLibraryFilterDialog(
                  context: context,
                  type: musicLibraryConfig,
                  current: LibraryFilterSelection.none,
                  options: const LibraryFilterOptions(
                    series: ['Daft Punk'],
                    publishers: ['Virgin'],
                    releaseYears: ['2001'],
                  ),
                );
              },
              child: const Text('Open filters'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    expect(find.text('Artist'), findsOneWidget);
    expect(find.text('Label'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Series'), findsNothing);
    expect(find.text('Publisher'), findsNothing);
  });

  testWidgets('filter dialog exposes location filter when paths exist',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showLibraryFilterDialog(
                  context: context,
                  type: comicsLibraryConfig,
                  current: LibraryFilterSelection.none,
                  options: const LibraryFilterOptions(
                    locations: ['Office > Shelf 2 > Short Box 1'],
                  ),
                );
              },
              child: const Text('Open filters'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();

    expect(find.text('Location'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('Any location'), findsOneWidget);
  });

  test('location filter matches exact location path', () {
    final entry = LibraryWorkspaceEntry(
      id: 'comic-1',
      mediaType: 'comic',
      title: 'Batman',
      storageBox: 'Office > Shelf 2 > Short Box 1',
      updatedAt: DateTime.utc(2026, 5, 22),
    );

    expect(
      libraryFilterMatches(
        entry,
        const LibraryFilterSelection(
          location: 'Office > Shelf 2 > Short Box 1',
        ),
      ),
      isTrue,
    );
    expect(
      libraryFilterMatches(
        entry,
        const LibraryFilterSelection(location: 'Office > Shelf 2'),
      ),
      isFalse,
    );
  });
}