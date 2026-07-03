import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_constants.dart';

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
    await pumpUntilSettled(tester);

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
    await pumpUntilSettled(tester);

    expect(find.text('Location'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await pumpUntilSettled(tester);

    expect(find.text('Any location'), findsOneWidget);
  });

  test('location filter matches exact location path', () {
    final entry = LibraryWorkspaceEntry(
      id: 'comic-1',
      mediaType: 'comic',
      title: 'Batman',
      locationPath: 'Office > Shelf 2 > Short Box 1',
      updatedAt: DateTime.utc(2026, 5, 22),
    );

    expect(
      libraryFilterMatches(
        entry,
        const LibraryFilterSelection(
          location: 'Office > Shelf 2 > Short Box 1',
        ),
        comicsMediaAdapter,
      ),
      isTrue,
    );
    expect(
      libraryFilterMatches(
        entry,
        const LibraryFilterSelection(location: 'Office > Shelf 2'),
        comicsMediaAdapter,
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
        comicsMediaAdapter,
      ),
      isTrue,
    );
    expect(
      libraryFilterMatches(
        entry,
        const LibraryFilterSelection(tag: 'Exclusive'),
        comicsMediaAdapter,
      ),
      isFalse,
    );
  });

  test('filter selection sanitization drops unsupported grade filters', () {
    const selection = LibraryFilterSelection(
      ownershipFilter: LibraryOwnershipFilter.missingGrade,
      grade: '9.8',
      condition: 'Mint',
      publisher: 'DC',
      country: 'US',
    );

    final sanitizedMusic = sanitizeLibraryFilterSelectionForType(
      selection,
      musicLibraryConfig,
    );
    expect(sanitizedMusic.ownershipFilter, LibraryOwnershipFilter.all);
    expect(sanitizedMusic.grade, isNull);
    expect(sanitizedMusic.condition, 'Mint');
    expect(sanitizedMusic.publisher, 'DC');
    expect(sanitizedMusic.country, 'US');

    final sanitizedComics = sanitizeLibraryFilterSelectionForType(
      selection,
      comicsLibraryConfig,
    );
    expect(
      sanitizedComics.ownershipFilter,
      LibraryOwnershipFilter.missingGrade,
    );
    expect(sanitizedComics.grade, '9.8');
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
    ], adapter: comicsMediaAdapter);

    expect(options.tags, ['Signed', 'Sketched', 'Variant']);
  });

  testWidgets('filter dialog exposes custom field filter and returns selection',
      (
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
                    adapter: comicsMediaAdapter,
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
    await pumpUntilSettled(tester);

    expect(find.text('Tracking status'), findsOneWidget);
    expect(find.text('Loan status'), findsOneWidget);
    expect(find.text('Date field'), findsOneWidget);
    expect(find.text('Custom field'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Location').last);
    await pumpUntilSettled(tester);

    expect(find.text('Location value'), findsOneWidget);

    await tester.tap(find.text('Apply'));
    await pumpUntilSettled(tester);

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
    await pumpUntilSettled(tester);

    expect(find.text('Tag'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'Sig');
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Signed').last);
    await pumpUntilSettled(tester);
    await tester.tap(find.text('Apply'));
    await pumpUntilSettled(tester);

    expect(selection, isNotNull);
    expect(selection!.tag, 'Signed');
  });
}
