import 'package:collectarr_app/features/library/workspace/layout/library_series_sidebar.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
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

  testWidgets('tree mode renders nested nodes and handles selection',
      (tester) async {
    List<LibraryFolderTreeNode>? selectedPath;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 260,
              height: 220,
              child: LibrarySeriesSidebar(
                series: const [
                  LibrarySeriesBucket(title: 'Batman', count: 2),
                ],
                selectedSeries: 'Batman',
                onSelectSeries: (_) {},
                folderDisplayMode: LibraryFolderDisplayMode.tree,
                treeRoots: const [
                  LibraryFolderTreeNode(
                    id: 'root',
                    label: '[All Comics]',
                    count: 2,
                    cumulativeCount: 2,
                    groupMode: LibraryGroupMode.series,
                    children: [
                      LibraryFolderTreeNode(
                        id: 'root|series=Batman',
                        label: 'Batman',
                        count: 2,
                        cumulativeCount: 2,
                        groupMode: LibraryGroupMode.series,
                        bucketValue: 'Batman',
                        children: const [],
                        isExpanded: false,
                      ),
                    ],
                    isExpanded: true,
                  ),
                ],
                selectedTreeNodeId: 'root|series=Batman',
                expandedTreeNodeIds: const {'root'},
                onSelectTreeNodePath: (path) => selectedPath = path,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('[All Comics]'), findsOneWidget);
    expect(find.text('Batman'), findsOneWidget);

    await tester.tap(find.text('Batman').last);

    expect(selectedPath, isNotNull);
    expect(selectedPath!.last.id, 'root|series=Batman');
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
