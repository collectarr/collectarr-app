import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';

/// Compatibility facade over kind-owned custom-episode tables.
///
/// This class only aggregates codec results and owns transaction mechanics.
/// TV/Anime coordinates and Drift table mappings live in their codecs.
class CustomEpisodesCacheRepository {
  CustomEpisodesCacheRepository(
    this._db, {
    required Iterable<CustomEpisodeCodec> codecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<String, CustomEpisodeCodec> _codecs;

  Future<List<CustomEpisode>> listByItemId(String itemId) async {
    final episodes = <CustomEpisode>[];
    for (final codec in _codecs.values) {
      episodes.addAll(await codec.listActive(_db, itemId: itemId));
    }
    episodes.sort(_compareEpisodes);
    return episodes;
  }

  Future<Map<int, List<CustomEpisode>>> listByItemIdGrouped(
    String itemId,
  ) async {
    final episodes = await listByItemId(itemId);
    final grouped = <int, List<CustomEpisode>>{};
    for (final episode in episodes) {
      final codec = _codecs[episode.seriesRef.kind];
      if (codec == null) continue;
      grouped.putIfAbsent(codec.groupKey(episode), () => <CustomEpisode>[]).add(
            episode,
          );
    }
    return grouped;
  }

  Future<List<CustomEpisode>> listActive() async {
    final episodes = <CustomEpisode>[];
    for (final codec in _codecs.values) {
      episodes.addAll(await codec.listActive(_db));
    }
    episodes.sort(_compareEpisodes);
    return episodes;
  }

  Future<CustomEpisode?> findById(String id) async {
    for (final codec in _codecs.values) {
      final episode = await codec.findById(_db, id);
      if (episode != null) return episode;
    }
    return null;
  }

  Future<void> upsert(CustomEpisode episode) async {
    await _db.transaction(() => _upsert(episode));
  }

  Future<void> upsertAll(List<CustomEpisode> episodes) async {
    if (episodes.isEmpty) return;
    await _db.transaction(() async {
      for (final episode in episodes) {
        await _upsert(episode);
      }
    });
  }

  Future<void> markDeleted(CustomEpisode episode, DateTime now) {
    return upsert(episode.copyWith(deletedAt: now, updatedAt: now));
  }

  Map<String, dynamic> toSyncPayload(CustomEpisode episode) {
    return _codecs[episode.seriesRef.kind]?.toSyncPayload(episode) ??
        episode.toSyncPayload();
  }

  Future<void> _upsert(CustomEpisode episode) {
    final codec = _codecs[episode.seriesRef.kind];
    if (codec == null) {
      throw ArgumentError.value(
        episode.seriesRef.kind,
        'episode.seriesRef.kind',
        'No custom episode codec is registered for this kind',
      );
    }
    return codec.upsert(_db, episode);
  }

  int _compareEpisodes(CustomEpisode left, CustomEpisode right) {
    final leftCodec = _codecs[left.seriesRef.kind];
    if (leftCodec != null && left.seriesRef.kind == right.seriesRef.kind) {
      return leftCodec.compare(left, right);
    }
    final item = left.itemId.compareTo(right.itemId);
    if (item != 0) return item;
    return left.id.compareTo(right.id);
  }
}
