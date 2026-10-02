import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a Movie Catalog Item projects into its workspace DTO', () {
    final source = LibraryWorkspaceSource(
      itemId: 'movie-1',
      catalogData: testWorkspaceCatalogData(testCatalogItem(
        id: 'movie-1',
        title: 'The Matrix',
        synopsis: 'A hacker discovers reality is a simulation.',
        video: const {'runtime_minutes': 136},
        kind: 'movie',
      ).asShelfCatalogItem),
    );

    final titleDto = const MovieWorkspaceProjector().project(
      source: source,
      entity: const LibraryCatalogItemNodeRef(catalogItemId: 'movie-1'),
    );

    expect(titleDto.title, 'The Matrix');
    expect(titleDto.runtimeMinutes, 136);
  });
}
