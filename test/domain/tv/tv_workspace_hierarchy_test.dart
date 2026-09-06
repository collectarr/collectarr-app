import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/hierarchy/domain/library_hierarchy_node.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_hierarchy_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_metadata.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_projector.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects a TV snapshot into the TV-owned workspace graph', () {
    final metadata = TvSeriesMetadata(
      title: 'The Expanse',
      firstAirDate: DateTime.utc(2015, 12, 14),
      lastAirDate: DateTime.utc(2022, 1, 14),
      status: 'Ended',
      network: 'Syfy',
      streamingService: 'Prime Video',
      contentRating: 'TV-14',
      seasonCount: 1,
      episodeCount: 1,
      episodeRuntimeMinutes: 43,
      seasons: [
        TvSeasonMetadata(
          seasonNumber: 1,
          title: 'Season 1',
          episodeCount: 1,
          episodes: [
            TvEpisodeMetadata(
              number: 1,
              title: 'Dulcinea',
              runtimeMinutes: 43,
            ),
          ],
        ),
      ],
    );
    final source = ShelfEntry(
      itemId: 'tv-expanse',
      catalogItem: CatalogItem(
        identity: const LibraryItemIdentity(
          id: 'tv-expanse',
          mediaKind: CatalogMediaKind.tv,
        ),
        kindMetadata: metadata,
      ),
      ownedItem: null,
    );

    final dto = const TvWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'tv-expanse'),
    );

    expect(dto, isA<TvWorkspaceDto>());
    expect(dto.series.typedId.value, 'tv-expanse');
    expect(dto.series.title, 'The Expanse');
    expect(dto.series.network, 'Syfy');
    expect(dto.series.seasons.single.typedId.value, 'tv-expanse:season:1');
    expect(
      dto.series.seasons.single.episodes.single.typedId.value,
      'tv-expanse:season:1:episode:1',
    );
    expect(dto.series.seasons.single.episodes.single.title, 'Dulcinea');
    expect(dto.firstAirDate, DateTime.utc(2015, 12, 14));
    expect(dto.streamingService, 'Prime Video');
    expect(dto.contentRating, 'TV-14');
  });

  test('maps typed TV seasons and episodes to generic hierarchy nodes', () {
    final season = TvCoreMapper.fromSeasonDto(
      TvSeasonDto.fromJson({
        'id': 'season-1',
        'series_id': 'series-1',
        'season_number': 1,
        'episode_count': 1,
        'episodes': [
          {
            'id': 'episode-1',
            'season_id': 'season-1',
            'episode_number': 1,
            'episode_title': 'Pilot',
            'runtime_minutes': 52,
            'air_date': '2020-01-01T00:00:00Z',
          },
        ],
      }),
    );

    final nodes = TvHierarchyMapper.toLibraryNodes([season]);

    expect(nodes, hasLength(1));
    expect(nodes.single.id, 'season-1');
    expect(nodes.single.level, LibraryHierarchyLevel.container);
    expect(nodes.single.metadata['kind'], 'tv_season');
    expect(nodes.single.secondaryLabel, '1 episodes');
    expect(nodes.single.children, hasLength(1));
    expect(nodes.single.children.single.id, 'episode-1');
    expect(nodes.single.children.single.label, 'Pilot');
    expect(nodes.single.children.single.secondaryLabel, '52 min · 2020');
    expect(nodes.single.children.single.metadata['kind'], 'tv_episode');
    expect(nodes.single.children.single.metadata['episodeNumber'], 1.0);
  });

  test('does not create hierarchy nodes from unrelated empty input', () {
    expect(TvHierarchyMapper.toLibraryNodes(const []), isEmpty);
  });
}
