import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_tracking_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_typed_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_profile.dart';
import 'package:collectarr_app/features/providers/domain/models/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_attribution.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_image_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_provenance.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists typed TV watch sessions, progress, and custom episodes',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TvTrackingRepository(db);
    final now = DateTime.utc(2026, 9, 5, 12);
    final seriesId = TvSeriesId('series-1');
    final seasonId = TvSeasonId('season-1');
    final episodeId = TvEpisodeId('episode-1');
    final targetRef = CatalogEntityRef(
      kind: CatalogMediaKind.tv.apiValue,
      entityType: CatalogEntityType.episode,
      id: episodeId.value,
    );

    await repository.upsertWatchSession(
      TvWatchSession(
        id: 'watch-1',
        seriesId: seriesId,
        episodeId: episodeId,
        targetRef: targetRef,
        seasonNumber: 1,
        episodeNumber: 1,
        sourceType: TrackingSourceType.streaming,
        watchedAt: now,
        updatedAt: now,
        rating: 5,
      ),
    );
    await repository.upsertEpisodeProgress(
      TvEpisodeProgress(
        seriesId: seriesId,
        seasonId: seasonId,
        episodeId: episodeId,
        seasonNumber: 1,
        episodeNumber: 1,
        watchedCount: 2,
        completed: true,
        lastWatchedAt: now,
        updatedAt: now,
      ),
    );
    await repository.upsertCustomEpisode(
      TvCustomEpisode(
        id: const TvEpisodeId('custom-1'),
        seriesId: seriesId,
        seasonNumber: 1,
        episodeNumber: 99,
        title: 'Bonus feature',
        updatedAt: now,
        runtimeMinutes: 12,
      ),
    );

    final sessions = await repository.listWatchSessions(seriesId);
    final progress = await repository.findEpisodeProgress(
      seriesId: seriesId,
      seasonId: seasonId,
      episodeId: episodeId,
    );
    final customEpisodes = await repository.listCustomEpisodes(seriesId);

    expect(sessions.single.episodeId, episodeId);
    expect(sessions.single.sourceType, TrackingSourceType.streaming);
    expect(progress?.watchedCount, 2);
    expect(progress?.completed, isTrue);
    expect(customEpisodes.single.id.value, 'custom-1');
    expect(customEpisodes.single.runtimeMinutes, 12);

    await repository.markWatchSessionDeleted(sessions.single, now);
    await repository.markCustomEpisodeDeleted(customEpisodes.single, now);
    expect(await repository.listWatchSessions(seriesId), isEmpty);
    expect(await repository.listCustomEpisodes(seriesId), isEmpty);
  });

  test(
      'typed TV provider mapper validates kind and falls back to provider image',
      () {
    final envelope = NormalizedProviderEnvelopeV1(
      provider: 'tmdb',
      providerItemId: '1396',
      kind: 'tv',
      normalized: const {
        'title': 'Breaking Bad',
        'status': 'Ended',
        'network': 'AMC',
      },
      images: const [
        ProviderImageRef(provider: 'tmdb', url: 'https://cdn/tv.jpg'),
      ],
      provenance: const ProviderProvenance(fetchedAt: '2026-09-05T00:00:00Z'),
      attribution: const ProviderAttribution(required: false),
    );

    final series = TvProviderTypedMapper.fromEnvelope(envelope);
    expect(series.id, '1396');
    expect(series.title, 'Breaking Bad');
    expect(series.network, 'AMC');
    expect(series.rawPayload['cover_image_url'], 'https://cdn/tv.jpg');

    expect(
      () => TvProviderTypedMapper.fromEnvelope(
        NormalizedProviderEnvelopeV1(
          provider: 'tmdb',
          providerItemId: '872585',
          kind: 'movie',
          normalized: const {'title': 'Wrong kind'},
          images: const [],
          provenance: const ProviderProvenance(fetchedAt: ''),
          attribution: const ProviderAttribution(required: false),
        ),
      ),
      throwsStateError,
    );
  });

  test('TV tracking profile owns video status labels', () {
    expect(tvTrackingProfile.name, 'TV');
    expect(
      tvTrackingProfile.normalizeStorageValue('completed'),
      'Watched',
    );
    expect(
      tvTrackingProfile.normalizeStorageValue('planned'),
      'Plan to watch',
    );
  });
}
