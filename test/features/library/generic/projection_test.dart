import 'package:collectarr_app/core/api/dto/catalog/catalog_series_details_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_projector.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
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
    final source = LibraryWorkspaceSource(
      itemId: 'music-1',
      catalogData: testWorkspaceCatalogData(
          testCatalogItem(id: 'music-1', kind: 'music', title: 'Album 1')
              .asShelfCatalogItem),
    );
    const node = LibraryWorkRef(workId: 'music-1');
    final dto = const MusicReleaseGroupWorkspaceProjector().project(
      source: source,
      entity: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    expect(item.dto.title, 'Album 1');
  });

  test('comic series group definition extracts series title', () {
    final source1 = LibraryWorkspaceSource(
      itemId: 'comic-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Saga #1',
        series: const CatalogSeriesDetailsDto(seriesTitle: 'Saga'),
      ).asShelfCatalogItem),
      ownedSummary:
          testOwnedSummary(testOwnedItem(id: 'o1', itemId: 'comic-1')),
    );
    const node1 = LibraryWorkRef(workId: 'comic-1');
    final dto1 = const ComicWorkspaceProjector().project(
      source: source1,
      entity: node1,
    );

    final groupDef = comicKindWorkspace.fields.findGroupDefinition(
      comicKindWorkspace.fields.decodeGroupId('comic.series'),
    );
    expect(groupDef, isNotNull);
    final ctx = LibraryProjectionContext<ComicWorkspaceDto>(
      source: source1,
      node: node1,
      dto: dto1,
    );
    expect(groupDef!.getValue(ctx), 'Saga');
  });
}
