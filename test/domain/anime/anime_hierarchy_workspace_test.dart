import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_episode.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_mapper.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps Anime-owned episodes into a generic hierarchy container', () {
    const media = AnimeMedia(
      id: AnimeMediaId('anime-1'),
      title: 'Cowboy Bebop',
      episodes: [
        AnimeEpisode(
          id: AnimeEpisodeId('episode-1'),
          seriesId: AnimeMediaId('anime-1'),
          episodeNumber: 1,
          title: 'Asteroid Blues',
          runtimeMinutes: 24,
        ),
      ],
    );

    final nodes = AnimeHierarchyMapper.toLibraryNodes(media);

    expect(nodes, hasLength(1));
    expect(nodes.single.id, 'anime-1:episodes');
    expect(nodes.single.level, LibraryHierarchyLevel.container);
    expect(nodes.single.children.single.label, 'Asteroid Blues');
    expect(nodes.single.children.single.metadata['kind'], 'anime_episode');
  });

  test('workspace mapper exposes a typed AnimeMedia graph', () {
    final item = testCatalogItemFromJson({
      'id': 'anime-2',
      'kind': 'anime',
      'title': 'Samurai Champloo',
      'cover_image_url': 'https://example.com/champloo.jpg',
      'episode_count': 26,
    });

    final media = AnimeWorkspaceMapper.fromCatalogItem(item);

    expect(media.id, const AnimeMediaId('anime-2'));
    expect(media.title, 'Samurai Champloo');
    expect(media.episodeCount, 26);
    expect(media.coverImageUrl, 'https://example.com/champloo.jpg');
  });
}
