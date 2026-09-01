import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/core/models/library_relation_node.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comic relation capability exposes a typed serial target', () {
    final source = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Saga #1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-1',
          seriesTitle: 'Saga',
        ),
      ),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: const ComicWorkspaceProjector().projectTitle(
        source: source,
        node: node,
      ),
    );

    final target = comicKindModule.relations!.targetFor(item);

    expect(target?.id, 'series-1');
    expect(target?.title, 'Saga');
    expect(target?.label, 'Series');
  });

  test('relation node accepts the current series relation transport keys', () {
    final node = LibraryRelationNode.fromJson({
      'id': 'relation-1',
      'relation_type': 'sequel',
      'target_series_id': 'series-2',
      'target_series_title': 'Saga: Reborn',
      'target_series_kind': 'comic',
    });

    expect(node.targetId, 'series-2');
    expect(node.targetTitle, 'Saga: Reborn');
    expect(node.targetKind, 'comic');
    expect(node.relationLabel, 'Sequel');
  });
}
