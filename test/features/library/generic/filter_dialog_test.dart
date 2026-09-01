import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/config/presentation/library_filter_presentation.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_constants.dart';
import '../../../helpers/test_data_factories.dart';

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
                    valuesByFilterId: {
                      'series': ['Daft Punk'],
                      'publisher': ['Virgin'],
                      'year': ['2001'],
                    },
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
                    valuesByFilterId: {
                      'location': ['Office > Shelf 2 > Short Box 1'],
                    },
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
    final source = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Batman',
      ),
      locationPath: 'Office > Shelf 2 > Short Box 1',
    );
    const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
    final dto = const ComicWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    expect(
      libraryFilterMatches(
        item,
        const LibraryFilterSelection(
          fieldValues: {
            'location': 'Office > Shelf 2 > Short Box 1',
          },
        ),
      ),
      isTrue,
    );
    expect(
      libraryFilterMatches(
        item,
        const LibraryFilterSelection(
          fieldValues: {'location': 'Office > Shelf 2'},
        ),
      ),
      isFalse,
    );
  });

  test('tag filter matches exact tag case-insensitively', () {
    final source = testShelfEntry(
      itemId: 'comic-1',
      kind: 'comic',
      title: 'Batman',
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        tags: 'Signed, Slabbed, Variant',
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
    final dto = const ComicWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    expect(
      libraryFilterMatches(
        item,
        const LibraryFilterSelection(fieldValues: {'tag': 'signed'}),
      ),
      isTrue,
    );
    expect(
      libraryFilterMatches(
        item,
        const LibraryFilterSelection(fieldValues: {'tag': 'Exclusive'}),
      ),
      isFalse,
    );
  });

  test('filter selection sanitization drops unsupported grade filters', () {
    const selection = LibraryFilterSelection(
      fieldValues: {
        'grade': LibraryFilterDefinition.missingValue,
        'condition': 'Mint',
        'publisher': 'DC',
        'country': 'US',
      },
    );

    final sanitizedMusic = sanitizeLibraryFilterSelectionForType(
      selection,
      musicLibraryConfig,
    );
    expect(sanitizedMusic.ownershipFilter, LibraryOwnershipFilter.all);
    expect(sanitizedMusic.fieldValue('grade'), isNull);
    expect(sanitizedMusic.fieldValue('condition'), 'Mint');
    expect(sanitizedMusic.fieldValue('publisher'), 'DC');
    expect(sanitizedMusic.fieldValue('country'), 'US');

    final sanitizedComics = sanitizeLibraryFilterSelectionForType(
      selection,
      comicsLibraryConfig,
    );
    expect(sanitizedComics.ownershipFilter, LibraryOwnershipFilter.all);
    expect(
      sanitizedComics.fieldValue('grade'),
      LibraryFilterDefinition.missingValue,
    );
  });

  test('filter options extract normalized tags from entries', () {
    final source1 = testShelfEntry(
      itemId: 'comic-1',
      kind: 'comic',
      title: 'Batman',
      ownedItem: testOwnedItem(
        id: 'owned-1',
        itemId: 'comic-1',
        tags: 'Signed, Variant',
      ),
    );
    const node1 = LibraryTitleNodeRef(titleItemId: 'comic-1');
    final dto1 = const ComicWorkspaceProjector().projectTitle(
      source: source1,
      node: node1,
    );
    final item1 = LibraryProjectionItem(
      source: source1,
      node: node1,
      dto: dto1,
    );

    final source2 = testShelfEntry(
      itemId: 'comic-2',
      kind: 'comic',
      title: 'Robin',
      ownedItem: testOwnedItem(
        id: 'owned-2',
        itemId: 'comic-2',
        tags: 'variant, Sketched',
      ),
    );
    const node2 = LibraryTitleNodeRef(titleItemId: 'comic-2');
    final dto2 = const ComicWorkspaceProjector().projectTitle(
      source: source2,
      node: node2,
    );
    final item2 = LibraryProjectionItem(
      source: source2,
      node: node2,
      dto: dto2,
    );

    final options = LibraryFilterOptions.fromEntries([item1, item2]);

    expect(options.valuesFor('tag'), ['Signed', 'Sketched', 'Variant']);
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
                    valuesByFilterId: {
                      'tag': ['Signed', 'Sketched', 'Variant'],
                    },
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
    expect(selection!.fieldValue('tag'), 'Signed');
  });
}
