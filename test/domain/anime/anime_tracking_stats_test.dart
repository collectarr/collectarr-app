import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/stats/anime_stats_capability.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data_factories.dart';

void main() {
  test('Anime owns an Anime-specific tracking profile', () {
    expect(animeKindModule.trackingProfile, same(animeTrackingProfile));
    expect(animeTrackingProfile.name, 'Anime');
    expect(
      animeTrackingProfile.normalizeStorageValue('completed'),
      'Watched',
    );
    expect(
      animeTrackingProfile.normalizeStorageValue('planned'),
      'Plan to watch',
    );
  });

  test('Anime stats use typed metadata for episode and facet summaries', () {
    final entries = [
      testShelfEntry(
        itemId: 'anime-1',
        kind: 'anime',
        catalogItem: testCatalogItem(
          id: 'anime-1',
          kind: 'anime',
          title: 'Frieren',
          payload: const {
            'format': 'tv',
            'episode_count': 28,
            'genres': ['Adventure', 'Fantasy'],
            'studios': ['Madhouse'],
            'source_material': 'manga',
          },
        ),
      ),
      testShelfEntry(
        itemId: 'anime-2',
        kind: 'anime',
        catalogItem: testCatalogItem(
          id: 'anime-2',
          kind: 'anime',
          title: 'A Place Further Than the Universe',
          payload: const {
            'format': 'tv',
            'episode_count': 13,
            'genres': ['Adventure', 'Drama'],
            'studios': ['Madhouse'],
            'source_material': 'original',
          },
        ),
      ),
    ];

    expect(AnimeStatsCapability.totalEpisodes(entries), 41);
    expect(AnimeStatsCapability.countGenres(entries), {
      'Adventure': 2,
      'Fantasy': 1,
      'Drama': 1,
    });
    expect(AnimeStatsCapability.countStudios(entries), {'Madhouse': 2});
    expect(AnimeStatsCapability.countFormats(entries), {'TV': 2});
    expect(AnimeStatsCapability.countSourceMaterial(entries), {
      'Manga': 1,
      'Original': 1,
    });
  });

  test('Anime stats ignore metadata from another kind', () {
    final entry = testShelfEntry(
      itemId: 'movie-1',
      kind: 'movie',
      catalogItem: testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Wrong kind',
        payload: const {'episode_count': 99},
      ),
    );

    expect(AnimeStatsCapability.totalEpisodes([entry]), 0);
    expect(AnimeStatsCapability.countGenres([entry]), isEmpty);
  });

  test('Anime metadata remains the stats input type', () {
    final entry = testShelfEntry(
      itemId: 'anime-1',
      kind: 'anime',
      catalogItem: testCatalogItem(
        id: 'anime-1',
        kind: 'anime',
        title: 'Typed anime',
        payload: const {'episode_count': 1},
      ),
    );
    expect(entry.catalogItem!.kindMetadata, isA<AnimeMetadata>());
  });
}
