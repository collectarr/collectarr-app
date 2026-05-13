import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
