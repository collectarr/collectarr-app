import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/features/library/tracking/custom_episode_codec.dart';

/// Aggregates kind-owned custom-episode tables at the collection boundary.
///
/// This class coordinates transactions. TV/Anime mapping and Drift table
/// persistence are supplied through their explicit codecs.
class CustomEpisodesRepository {
  CustomEpisodesRepository(
    this._db, {
    required Iterable<CustomEpisodeCodec> codecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, CustomEpisodeCodec> _codecs;

  Future<List<CustomEpisode>> listByCatalogRef(
    CatalogEntityRef catalogRef,
  ) async {
    final codec = _codecs[catalogRef.mediaKind];
    if (codec == null) return const [];
    final episodes = await codec.listActive(
      _db,
      catalogRef: catalogRef,
    );
    episodes.sort(_compareEpisodes);
    return episodes;
  }

  Future<Map<int, List<CustomEpisode>>> listByCatalogRefGrouped(
    CatalogEntityRef catalogRef,
  ) async {
    final episodes = await listByCatalogRef(catalogRef);
    final grouped = <int, List<CustomEpisode>>{};
    for (final episode in episodes) {
      final codec = _codecs[episode.seriesRef.mediaKind];
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
    final codec = _codecs[episode.seriesRef.mediaKind];
    if (codec == null) {
      throw StateError(
        'No custom-episode codec is registered for kind '
        '"${episode.seriesRef.kind}".',
      );
    }
    return codec.toSyncPayload(episode);
  }

  Future<void> _upsert(CustomEpisode episode) {
    final codec = _codecs[episode.seriesRef.mediaKind];
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
    final leftCodec = _codecs[left.seriesRef.mediaKind];
    if (leftCodec != null &&
        left.seriesRef.mediaKind == right.seriesRef.mediaKind) {
      return leftCodec.compare(left, right);
    }
    final item = left.itemId.compareTo(right.itemId);
    if (item != 0) return item;
    return left.id.compareTo(right.id);
  }
}
