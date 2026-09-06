import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_custom_episode_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('custom episode sync payload uses catalog ref', () {
    final ref = CatalogEntityRef(
      kind: 'tv',
      entityType: CatalogEntityType.work,
      id: 'series-1',
    );
    final episode = CustomEpisode(
      id: 'custom-1',
      seriesRef: ref,
      seasonNumber: 1,
      episodeNumber: 3,
      title: 'Custom title',
      overview: 'Custom overview',
      airDate: '2026-07-05',
      runtimeMinutes: 24,
      updatedAt: DateTime.utc(2026, 7, 5),
    );

    expect(episode.itemId, 'series-1');
    expect(episode.toSyncPayload(), {
      'catalog_ref': ref.toJson(),
      'season_number': 1,
      'episode_number': 3,
      'title': 'Custom title',
      'overview': 'Custom overview',
      'air_date': '2026-07-05',
      'runtime_minutes': 24,
    });

    final roundTrip = const TvCustomEpisodeCodec().fromSyncPayload(
      payload: episode.toSyncPayload(),
      id: 'custom-1',
      updatedAt: DateTime.utc(2026, 7, 5),
    );

    expect(roundTrip.seriesRef.id, 'series-1');
    expect(roundTrip.seriesRef.entityType, CatalogEntityType.work);
    expect(roundTrip.title, 'Custom title');
  });
}
