import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GameWorkspaceProjector produces a typed GameWorkspaceDto with correct title', () {
    final source = ShelfEntry(
      itemId: 'game-1',
      catalogItem: CatalogItemDto(
        id: 'game-1',
        title: 'Example Game',
        kind: 'game',
      ),
    );

    final dto = const GameWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'game-1'),
    );

    expect(dto.title, 'Example Game');
    expect(dto.game.work.title, 'Example Game');
  });
}
