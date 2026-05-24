import 'package:collectarr_app/core/models/custom_field.dart';
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

  test('tag filter matches exact tag case-insensitively', () {
    final entry = LibraryWorkspaceEntry(
      id: 'comic-1',
      mediaType: 'comic',
      title: 'Batman',
      tags: 'Signed, Slabbed, Variant',
      updatedAt: DateTime.utc(2026, 5, 22),
    );

    expect(
      libraryFilterMatches(
        entry,
        const LibraryFilterSelection(tag: 'signed'),
      ),
      isTrue,
    );
    expect(
      libraryFilterMatches(
        entry,
        const LibraryFilterSelection(tag: 'Exclusive'),
      ),
      isFalse,
    );
  });

  test('filter options extract normalized tags from entries', () {
    final options = LibraryFilterOptions.fromEntries([
      LibraryWorkspaceEntry(
        id: 'comic-1',
        mediaType: 'comic',
        title: 'Batman',
        tags: 'Signed, Variant',
        updatedAt: DateTime.utc(2026, 5, 22),
      ),
      LibraryWorkspaceEntry(
        id: 'comic-2',
        mediaType: 'comic',
        title: 'Robin',
        tags: 'variant, Sketched',
        updatedAt: DateTime.utc(2026, 5, 22),
      ),
    ]);

    expect(options.tags, ['Signed', 'Sketched', 'Variant']);
  });

  testWidgets('filter dialog exposes custom field filter and returns selection', (
    tester,
  ) async {
    LibraryFilterSelection? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selection = await showLibraryFilterDialog(
                  context: context,
                  type: comicsLibraryConfig,
                  current: LibraryFilterSelection.none,
                  options: LibraryFilterOptions.fromEntries(
                    const [],
                    customFieldDefinitions: [
                      CustomFieldDefinition(
                        id: 'cf-location',
                        name: 'Location',
                        fieldType: 'select',
                        options: '["Shelf A","Shelf B"]',
                        createdAt: DateTime.utc(2026, 1, 1),
                      ),
                    ],
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

    expect(find.text('Tracking status'), findsOneWidget);
    expect(find.text('Loan status'), findsOneWidget);
    expect(find.text('Date field'), findsOneWidget);
    expect(find.text('Custom field'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Location').last);
    await tester.pumpAndSettle();

    expect(find.text('Location value'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(selection, isNotNull);
    expect(selection!.customFieldDefinitionId, 'cf-location');
    expect(selection!.customFieldValue, isNull);
  });

  testWidgets('filter dialog exposes tag autocomplete and returns selection', (
    tester,
  ) async {
    LibraryFilterSelection? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selection = await showLibraryFilterDialog(
                  context: context,
                  type: comicsLibraryConfig,
                  current: LibraryFilterSelection.none,
                  options: const LibraryFilterOptions(
                    tags: ['Signed', 'Sketched', 'Variant'],
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

    expect(find.text('Tag'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'Sig');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Signed').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(selection, isNotNull);
    expect(selection!.tag, 'Signed');
  });
}