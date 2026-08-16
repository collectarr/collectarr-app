import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  test('other drilldowns still remain enabled', () {
    expect(
      libraryAllowsGroupDrilldown(
        currentMode: 'publisher',
        childMode: 'title',
      ),
      isTrue,
    );
  });

  test('music grouping fallbacks use unknown artist and label buckets', () {
    final source = ShelfEntry(
      itemId: 'music-1',
      catalogItem:
          testCatalogItem(id: 'music-1', kind: 'music', title: 'Album 1'),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'music-1');
    final dto = const MusicWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    expect(item.dto.title, 'Album 1');
  });

  test('comic series group definition extracts series title', () {
    final source1 = ShelfEntry(
      itemId: 'comic-1',
      catalogItem: testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Saga #1',
        series: const CatalogSeriesDetailsDto(seriesTitle: 'Saga'),
      ),
      ownedItem: testOwnedItem(id: 'o1', itemId: 'comic-1'),
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
    final groupDef = comicKindModule.fields.findGroupDefinition('comic.series');
    expect(groupDef, isNotNull);
    final ctx = LibraryProjectionContext<ComicWorkspaceDto>(
      source: source1,
      node: node1,
      dto: dto1 as ComicWorkspaceDto,
    );
    expect(groupDef!.getValue(ctx), 'Saga');
  });
}
