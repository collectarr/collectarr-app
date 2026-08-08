import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book workspace projector builds typed book dto', () {
    final source = ShelfEntry(
      itemId: 'book-1',
      catalogItem: CatalogItemDto(
        id: 'book-1',
        title: 'Guards! Guards!',
        publisher: 'Victor Gollancz Ltd',
        kind: 'book',
      ),
    );

    final dto = const BookWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'book-1'),
    );

    expect(dto.id, 'book-1');
    expect(dto.title, 'Guards! Guards!');
    expect(dto.publisher, 'Victor Gollancz Ltd');
  });
}
