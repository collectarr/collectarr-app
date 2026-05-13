import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/comics/comics_workspace_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects workspace series visible items selection and missing issues',
      () {
    final items = [
      _comic(id: 'batman-1', title: 'Batman', itemNumber: '1'),
      _comic(id: 'superman-4', title: 'Superman', itemNumber: '4'),
      _comic(id: 'superman-1', title: 'Superman', itemNumber: '1'),
      _comic(id: 'superman-2', title: 'Superman', itemNumber: '2'),
    ];

    final projection = ComicsWorkspaceProjection.fromItems(
      items: items,
      selectedSeries: 'Superman',
      selectedItemId: 'superman-2',
    );

    expect(
      projection.series.map((bucket) => '${bucket.title}:${bucket.count}'),
      ['Batman:1', 'Superman:3'],
    );
    expect(
      projection.visibleItems.map((item) => item.id),
      ['superman-4', 'superman-1', 'superman-2'],
    );
    expect(projection.selectedItem?.id, 'superman-2');
    expect(projection.missingIssues, [3]);
    expect(projection.totalCount, 4);
    expect(projection.visibleCount, 3);
  });

  test('falls back to the first visible item when selected item is unavailable',
      () {
    final projection = ComicsWorkspaceProjection.fromItems(
      items: [
        _comic(id: 'action-1', title: 'Action Comics', itemNumber: '1'),
        _comic(id: 'action-2', title: 'Action Comics', itemNumber: '2'),
      ],
      selectedSeries: 'Action Comics',
      selectedItemId: 'missing',
    );

    expect(projection.selectedItem?.id, 'action-1');
    expect(projection.missingIssues, isEmpty);
  });
}

CatalogItem _comic({
  required String id,
  required String title,
  required String itemNumber,
}) {
  return CatalogItem(
    id: id,
    kind: 'comic',
    title: title,
    itemNumber: itemNumber,
  );
}
