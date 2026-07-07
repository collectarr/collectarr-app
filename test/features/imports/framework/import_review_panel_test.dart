import 'package:collectarr_app/features/imports/framework/import_review_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('import review panel renders items and clear action', (tester) async {
    var cleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImportReviewPanel(
            title: 'Review',
            items: [
              ImportReviewItem(
                title: 'Dune',
                description: 'Movie · TMDB',
                trailingLabel: 'Proposal 12',
                actions: [
                  ImportReviewAction(
                    label: 'Remove',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
            onClearAll: () {
              cleared = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Proposal 12'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);

    await tester.tap(find.text('Clear all'));
    await tester.pump();

    expect(cleared, isTrue);
  });
}
