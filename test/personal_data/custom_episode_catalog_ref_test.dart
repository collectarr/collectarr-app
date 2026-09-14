import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_custom_episode_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV custom episode sync payload uses the TV-owned catalog ref', () {
    final ref = CatalogEntityRef(
      kind: CatalogMediaKind.tv,
      entityType: const CatalogEntityTypeId('work'),
      id: 'series-1',
    );
    final episode = TvCustomEpisode(
      id: const TvEpisodeId('custom-1'),
      seriesId: const TvSeriesId('series-1'),
      seasonNumber: 1,
      episodeNumber: 3,
      title: 'Custom title',
      description: 'Custom overview',
      airDate: DateTime.utc(2026, 7, 5),
      runtimeMinutes: 24,
      updatedAt: DateTime.utc(2026, 7, 5),
    );

    const codec = TvCustomEpisodeCodec();
    final payload = codec.toSyncPayload(episode);

    expect(payload, {
      'catalog_ref': ref.toJson(),
      'season_number': 1,
      'episode_number': 3,
      'title': 'Custom title',
      'description': 'Custom overview',
      'air_date': '2026-07-05T00:00:00.000Z',
      'runtime_minutes': 24,
    });

    final roundTrip = codec.fromSyncPayload(
      payload: payload,
      id: 'custom-1',
      updatedAt: DateTime.utc(2026, 7, 5),
    );

    expect(roundTrip.seriesId.value, 'series-1');
    expect(roundTrip.title, 'Custom title');
    expect(roundTrip.description, 'Custom overview');
  });
}
