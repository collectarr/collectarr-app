import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('movie work and release project into workspace dtos', () {
    final source = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: CatalogItemDto(
        id: 'movie-1',
        title: 'The Matrix',
        synopsis: 'A hacker discovers reality is a simulation.',
        video: const {'runtime_minutes': 136},
        kind: 'movie',
      ),
    );

    final titleDto = const MovieWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'movie-1'),
    );

    expect(titleDto.title, 'The Matrix');
    expect(titleDto.movie.technical.runtimeMinutes, 136);
  });
}
