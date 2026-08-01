import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('boardgame workspace projector builds typed boardgame dto', () {
    const source = ShelfEntry(
      catalogItem: CatalogItemDto(
        id: 'boardgame-1',
        title: 'Catan',
        kind: 'boardgame',
      ),
    );

    final dto = const BoardGameWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'boardgame-1'),
    );

    expect(dto.title, 'Catan');
    expect(dto.kind, 'boardgame');
  });
}
