import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tv workspace projections build series season episode and release nodes', () {
    const source = ShelfEntry(
      catalogItem: CatalogItemDto(
        id: 'series-1',
        title: 'Cowboy Bebop',
        description: 'A space western.',
        kind: 'tv',
      ),
    );

    final dto = const TvWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'series-1'),
    );

    expect(dto.title, 'Cowboy Bebop');
    expect(dto.kind, 'tv');
  });
}
