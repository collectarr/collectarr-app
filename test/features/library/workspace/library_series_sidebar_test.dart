import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('series sidebar renders buckets and handles selection',
      (tester) async {
    String? selected;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 260,
              height: 180,
              child: LibrarySeriesSidebar(
                series: const [
                  LibrarySeriesBucket(
                    title: 'Action Comics',
                    count: 12,
                    ownedCount: 6,
                  ),
                  LibrarySeriesBucket(title: 'Superman', count: 4),
                ],
                selectedSeries: 'Superman',
                onSelectSeries: (value) => selected = value,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Series'), findsOneWidget);
    expect(find.text('Action Comics'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Superman'), findsOneWidget);

    await tester.tap(find.text('Action Comics'));

    expect(selected, 'Action Comics');
  });

  test('bucket labels include completion percentages when available', () {
    expect(
      libraryBucketLabel(
        const LibrarySeriesBucket(title: 'Action Comics', count: 12),
      ),
      'Action Comics 12',
    );
    expect(
      libraryBucketLabel(
        const LibrarySeriesBucket(
          title: 'Saga',
          count: 6,
          ownedCount: 3,
        ),
      ),
      'Saga 6 (50%)',
    );
  });
}
