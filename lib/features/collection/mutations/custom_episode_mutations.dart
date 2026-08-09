import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class CustomEpisodeMutations {
  const CustomEpisodeMutations({
    required this.customEpisodes,
    required this.syncQueue,
    required this.mutationRunner,
    required this.events,
    this.idGenerator = _defaultIdGenerator,
  });

  final CustomEpisodesCacheRepository customEpisodes;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final CollectionEventBus events;
  final IdGenerator idGenerator;

  Future<CustomEpisode> upsertCustomEpisode({
    String? id,
    required CatalogEntityRef catalogRef,
    required int seasonNumber,
    required int episodeNumber,
    required String title,
    String? overview,
    String? airDate,
    int? runtimeMinutes,
    String? stillImageUrl,
    String? localImagePath,
    String? thumbnailImageUrl,
  }) async {
    final now = DateTime.now().toUtc();
    final episode = CustomEpisode(
      id: id ?? idGenerator(),
      seriesRef: catalogRef,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      title: title,
      overview: overview,
      airDate: airDate,
      runtimeMinutes: runtimeMinutes,
      stillImageUrl: stillImageUrl,
      localImagePath: localImagePath,
      thumbnailImageUrl: thumbnailImageUrl,
      updatedAt: now,
    );

    await mutationRunner.run(
      action: () async {
        await customEpisodes.upsert(episode);
        await syncQueue.enqueue(_syncChangeForCustomEpisode(episode, 'upsert', now));
      },
      eventsToEmit: [const CustomEpisodeChanged()],
    );

    return episode;
  }

  Future<void> removeCustomEpisode(CustomEpisode episode) async {
    final now = DateTime.now().toUtc();
    final deleted = episode.copyWith(deletedAt: now, updatedAt: now);

    await mutationRunner.run(
      action: () async {
        await customEpisodes.markDeleted(episode, now);
        await syncQueue.enqueue(_syncChangeForCustomEpisode(deleted, 'delete', now));
      },
      eventsToEmit: [const CustomEpisodeChanged()],
    );
  }

  SyncChange _syncChangeForCustomEpisode(
    CustomEpisode episode,
    String action,
    DateTime now,
  ) {
    return SyncChange(
      id: 'custom_episode:${episode.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'custom_episode',
      entityId: episode.id,
      action: action,
      payload: episode.toSyncPayload(),
      clientChangedAt: now,
    );
  }
}
