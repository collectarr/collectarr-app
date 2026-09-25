import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_tracking_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_mapper.dart';
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
      kind: CatalogMediaKind.tv,
      entityType: const CatalogEntityTypeId('episode'),
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

  test('TV workspace mapping builds the active typed series model', () {
    final series = TvWorkspaceMapper.fromCatalogItem(
      CatalogItemDto.raw(
        id: '1396',
        mediaKind: CatalogMediaKind.tv,
        common: const CatalogCommonDto(
          title: 'Breaking Bad',
          coverImageUrl: 'https://cdn/tv.jpg',
        ),
        payload: const {'status': 'Ended', 'network': 'AMC'},
      ),
    );

    expect(series.id, '1396');
    expect(series.title, 'Breaking Bad');
    expect(series.network, 'AMC');
    expect(series.status, 'Ended');
    expect(series.coverImageUrl, 'https://cdn/tv.jpg');
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
