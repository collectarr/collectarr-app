import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_filter_store.dart';
import 'package:collectarr_app/features/comics/comics_grouping_store.dart';
import 'package:collectarr_app/features/comics/comics_workspace_projection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('comics filter dialog returns selected filters', (tester) async {
    ComicsFilterSelection? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                selection = await showDialog<ComicsFilterSelection>(
                  context: context,
                  builder: (_) => const ComicsFilterDialog(
                    initialSelection: ComicsFilterSelection(
                      ownershipFilter: ComicsOwnershipFilter.all,
                    ),
                    gradeOptions: ['9.8'],
                    conditionOptions: ['Near Mint'],
                    publisherOptions: ['Marvel'],
                    releaseYearOptions: ['2026'],
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All comics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Owned').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(selection?.ownershipFilter, ComicsOwnershipFilter.owned);
    expect(selection?.publisher, isNull);
  });

  test('ownership filter labels are user-facing', () {
    expect(
      comicsOwnershipFilterLabel(ComicsOwnershipFilter.missingGrade),
      'Missing grade',
    );
  });

  test('filter selection counts active filters', () {
    const selection = ComicsFilterSelection(
      ownershipFilter: ComicsOwnershipFilter.owned,
      publisher: 'DC',
      releaseYear: '2026',
      missingCover: true,
    );

    expect(selection.hasActiveFilters, isTrue);
    expect(selection.activeFilterCount, 4);
    expect(ComicsFilterSelection.none.activeFilterCount, 0);
  });

  test('quick shelf views map to reusable filter selections', () {
    expect(
      ComicsShelfQuickView.owned.filters.ownershipFilter,
      ComicsOwnershipFilter.owned,
    );
    expect(ComicsShelfQuickView.missingCovers.filters.missingCover, isTrue);
    expect(
      ComicsShelfQuickView.missingMetadata.filters.missingMetadata,
      isTrue,
    );
    expect(
      ComicsShelfQuickView.missingMetadata.filters.quickView,
      ComicsShelfQuickView.missingMetadata,
    );
    expect(
      const ComicsFilterSelection(
        ownershipFilter: ComicsOwnershipFilter.owned,
        publisher: 'DC',
      ).quickView,
      isNull,
    );
  });

  test('filter store restores and clears persisted filters', () async {
    const store = ComicsFilterPreferenceStore();

    await store.write(
      const ComicsFilterSelection(
        ownershipFilter: ComicsOwnershipFilter.wishlist,
        grade: '9.8',
        publisher: 'DC',
        missingCover: true,
      ),
    );

    final restored = await store.read();

    expect(restored.ownershipFilter, ComicsOwnershipFilter.wishlist);
    expect(restored.grade, '9.8');
    expect(restored.publisher, 'DC');
    expect(restored.missingCover, isTrue);
    expect(restored.activeFilterCount, 4);

    await store.write(ComicsFilterSelection.none);
    final cleared = await store.read();
    final prefs = await SharedPreferences.getInstance();

    expect(cleared.hasActiveFilters, isFalse);
    expect(prefs.getString('comics.filters.publisher'), isNull);
  });

  test('grouping store restores selected shelf grouping mode', () async {
    const store = ComicsGroupingPreferenceStore();

    await store.write(ComicsShelfGroupMode.publisher);

    expect(await store.read(), ComicsShelfGroupMode.publisher);
  });
}
