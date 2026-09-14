import 'dart:async';

import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_tracking_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:uuid/uuid.dart';

typedef TvCustomEpisodeIdGenerator = String Function();

String _defaultTvCustomEpisodeId() => const Uuid().v4();

/// TV-owned custom episode mutations.
///
/// This deliberately lives under TV. Collection contributes only the generic
/// mutation runner and sync queue; it does not construct episode coordinates.
final class TvCustomEpisodeMutations {
  const TvCustomEpisodeMutations({
    required this.tracking,
    required this.syncQueue,
    required this.mutationRunner,
    this.idGenerator = _defaultTvCustomEpisodeId,
  });

  final TvTrackingRepository tracking;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final TvCustomEpisodeIdGenerator idGenerator;

  Future<TvCustomEpisode> upsertCustomEpisode({
    String? id,
    required TvSeriesId seriesId,
    required int seasonNumber,
    required int episodeNumber,
    required String title,
    String? description,
    DateTime? airDate,
    int? runtimeMinutes,
    String? stillImageUrl,
    String? localImagePath,
    String? thumbnailImageUrl,
  }) async {
    final now = DateTime.now().toUtc();
    final episode = TvCustomEpisode(
      id: TvEpisodeId(id ?? idGenerator()),
      seriesId: seriesId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      title: title,
      description: description,
      airDate: airDate,
      runtimeMinutes: runtimeMinutes,
      stillImageUrl: stillImageUrl,
      localImagePath: localImagePath,
      thumbnailImageUrl: thumbnailImageUrl,
      updatedAt: now,
    );

    await mutationRunner.run(
      action: () async {
        await tracking.upsertCustomEpisode(episode);
        await syncQueue.enqueue(_syncChange(episode, 'upsert', now));
      },
      eventsToEmit: const [CustomEpisodeChanged()],
    );
    return episode;
  }

  Future<void> removeCustomEpisode(TvCustomEpisode episode) async {
    final now = DateTime.now().toUtc();
    final deleted = TvCustomEpisode(
      id: episode.id,
      seriesId: episode.seriesId,
      seasonNumber: episode.seasonNumber,
      episodeNumber: episode.episodeNumber,
      title: episode.title,
      description: episode.description,
      airDate: episode.airDate,
      runtimeMinutes: episode.runtimeMinutes,
      stillImageUrl: episode.stillImageUrl,
      localImagePath: episode.localImagePath,
      thumbnailImageUrl: episode.thumbnailImageUrl,
      updatedAt: now,
      deletedAt: now,
    );
    await mutationRunner.run(
      action: () async {
        await tracking.markCustomEpisodeDeleted(episode, now);
        await syncQueue.enqueue(_syncChange(deleted, 'delete', now));
      },
      eventsToEmit: const [CustomEpisodeChanged()],
    );
  }

  SyncChange _syncChange(
    TvCustomEpisode episode,
    String action,
    DateTime now,
  ) {
    return SyncChange(
      id: 'custom_episode:${episode.id.value}:$action:'
          '${now.millisecondsSinceEpoch}',
      entityType: 'custom_episode',
      entityId: episode.id.value,
      action: action,
      payload: {
        'catalog_ref': {
          'kind': 'tv',
          'entity_type': 'work',
          'id': episode.seriesId.value,
        },
        'season_number': episode.seasonNumber,
        'episode_number': episode.episodeNumber,
        'title': episode.title,
        if (episode.description != null) 'description': episode.description,
        if (episode.airDate != null)
          'air_date': episode.airDate!.toUtc().toIso8601String(),
        if (episode.runtimeMinutes != null)
          'runtime_minutes': episode.runtimeMinutes,
        if (episode.stillImageUrl != null)
          'still_image_url': episode.stillImageUrl,
        if (episode.localImagePath != null)
          'local_image_path': episode.localImagePath,
        if (episode.thumbnailImageUrl != null)
          'thumbnail_image_url': episode.thumbnailImageUrl,
      },
      clientChangedAt: now,
    );
  }
}
