import 'package:collectarr_app/features/comics/comics_missing_issues.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('missing issues dialog renders issue actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => showComicsMissingIssuesDialog(
                  context,
                  selectedSeries: 'Superman, Vol. 4',
                  missingIssues: const [3, 8],
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Missing issues: Superman, Vol. 4'), findsOneWidget);
    expect(find.text('#3'), findsOneWidget);
    expect(find.text('#8'), findsOneWidget);
    expect(find.text('Search Core'), findsNWidgets(2));
    expect(find.text('Wishlist'), findsNWidgets(2));
    expect(find.text('Propose'), findsNWidgets(2));
  });
}
