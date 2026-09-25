import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  group('Movie Kind Vertical Slice Tests (C8)', () {
    test(
        'MovieCatalogMetadata and MovieReleaseMetadata serialize and deserialize full domain fields',
        () {
      final metadata = MovieCatalogMetadata(
        title: 'Inception',
        originalTitle: 'Inception',
        sortTitle: 'Inception',
        synopsis:
            'A thief who steals corporate secrets through dream-sharing technology.',
        genres: const ['Action', 'Sci-Fi', 'Thriller'],
        runtimeMinutes: 148,
        audienceRating: '8.8',
        ageRating: 'PG-13',
        studio: 'Warner Bros. Pictures',
        productionCompanies: const ['Syncopy', 'Legendary Pictures'],
        country: 'US',
        originalLanguage: 'en',
        releaseDate: DateTime(2010, 7, 16),
        directors: const [
          MoviePersonCredit(name: 'Christopher Nolan', role: 'Director')
        ],
        writers: const [
          MoviePersonCredit(name: 'Christopher Nolan', role: 'Writer')
        ],
        producers: const [
          MoviePersonCredit(name: 'Emma Thomas', role: 'Producer')
        ],
        cast: const [
          MoviePersonCredit(name: 'Leonardo DiCaprio', character: 'Dom Cobb'),
          MoviePersonCredit(name: 'Joseph Gordon-Levitt', character: 'Arthur'),
        ],
      );

      final json = metadata.toJson();
      final restored = MovieCatalogMetadata.fromJson(json);

      expect(restored.title, 'Inception');
      expect(restored.originalTitle, 'Inception');
      expect(restored.runtimeMinutes, 148);
      expect(restored.ageRating, 'PG-13');
      expect(restored.studio, 'Warner Bros. Pictures');
      expect(restored.directors.first.name, 'Christopher Nolan');
      expect(restored.writers.first.name, 'Christopher Nolan');
      expect(restored.producers.first.name, 'Emma Thomas');
      expect(restored.cast.first.name, 'Leonardo DiCaprio');
      expect(restored.cast.first.character, 'Dom Cobb');
    });

    test('MovieWorkspaceProjector projects metadata and schema fields', () {
      final movieMeta = MovieCatalogMetadata(
        title: 'Oppenheimer',
        originalTitle: 'Oppenheimer',
        runtimeMinutes: 180,
        ageRating: 'R',
        studio: 'Universal Pictures',
        directors: const [MoviePersonCredit(name: 'Christopher Nolan')],
        writers: const [MoviePersonCredit(name: 'Christopher Nolan')],
        producers: const [MoviePersonCredit(name: 'Emma Thomas')],
      );

      final shelfEntry = LibraryWorkspaceSource(
        itemId: 'movie_1',
        catalogData: testWorkspaceCatalogData(CatalogItemDto(
          identity: const LibraryItemIdentity(
            id: 'movie_1',
            mediaKind: CatalogMediaKind.movie,
          ),
          kindMetadata: movieMeta,
        ).asShelfCatalogItem),
        ownedSummary: testOwnedSummary(testOwnedItem(
          id: 'owned_1',
          catalogRef: const CatalogEntityRef(
            id: 'movie_1',
            kind: CatalogMediaKind.movie,
            entityType: CatalogEntityTypeId('work'),
          ),
          condition: 'Mint',
          updatedAt: DateTime.now(),
        )),
      );

      const projector = MovieWorkspaceProjector();
      const node = LibraryWorkRef(
        workId: 'movie_1',
      );
      final dto = projector.project(
        source: shelfEntry,
        entity: node,
      );

      expect(dto.metadata?.title, 'Oppenheimer');
      expect(dto.director, 'Christopher Nolan');
      expect(dto.writer, 'Christopher Nolan');
      expect(dto.producer, 'Emma Thomas');
      expect(dto.studio, 'Universal Pictures');
      expect(dto.runtimeMinutes, 180);
      expect(dto.originalTitle, 'Oppenheimer');
      expect(dto.ageRating, 'R');

      final ctx = LibraryProjectionContext<MovieWorkspaceDto>(
        source: shelfEntry,
        node: node,
        dto: dto,
      );

      expect(MovieWorkWorkspaceFields.title.getValue(ctx), 'Oppenheimer');
      expect(
          MovieWorkWorkspaceFields.director.getValue(ctx), 'Christopher Nolan');
      expect(
          MovieWorkWorkspaceFields.writer.getValue(ctx), 'Christopher Nolan');
      expect(MovieWorkWorkspaceFields.producer.getValue(ctx), 'Emma Thomas');
      expect(MovieReleaseWorkspaceFields.publisher.getValue(ctx),
          'Universal Pictures');
      expect(MovieWorkWorkspaceFields.runtimeMinutes.getValue(ctx), 180);
      expect(
          MovieWorkWorkspaceFields.originalTitle.getValue(ctx), 'Oppenheimer');
      expect(MovieWorkWorkspaceFields.ageRating.getValue(ctx), 'R');
    });
  });
}
