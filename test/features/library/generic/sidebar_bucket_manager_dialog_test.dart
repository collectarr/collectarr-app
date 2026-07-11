import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bucket manager helpers fall back for stale unsupported group modes', () {
    expect(
      () => libraryGroupModeSupportsBucketManagement(
        moviesLibraryConfig,
        'story_arc',
      ),
      returnsNormally,
    );
    expect(
      libraryGroupModeSupportsBucketManagement(
        moviesLibraryConfig,
        'story_arc',
      ),
      isFalse,
    );

    expect(
      () => libraryBucketManagerListLabel(
        'audience_rating',
        musicLibraryConfig,
      ),
      returnsNormally,
    );
    expect(
      libraryBucketManagerListLabel(
        'audience_rating',
        musicLibraryConfig,
      ),
      isNotEmpty,
    );
  });

  testWidgets('bucket manager dialog exposes merge action', (tester) async {
    String? mergedFrom;
    String? mergedInto;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showLibraryBucketManagerDialog(
                  context: context,
                  type: moviesLibraryConfig,
                  groupMode: 'genre',
                  accent: Colors.cyan,
                  entries: const [
                    LibraryBucketManagerEntry(label: 'Action', count: 8),
                    LibraryBucketManagerEntry(label: 'Drama', count: 4),
                  ],
                  onRenameBucket: (_, __) async => 0,
                  onMergeBucket: (currentLabel, targetLabel) async {
                    mergedFrom = currentLabel;
                    mergedInto = targetLabel;
                    return 3;
                  },
                  onDeleteBucket: (_) async => 0,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Merge Action'), findsOneWidget);

    await tester.tap(find.byTooltip('Merge Action'));
    await tester.pumpAndSettle();

    expect(find.text('Merge Action into...'), findsOneWidget);

    await tester.tap(find.text('Merge'));
    await tester.pump();
    await tester.pump();

    expect(mergedFrom, 'Action');
    expect(mergedInto, 'Drama');
  });
}