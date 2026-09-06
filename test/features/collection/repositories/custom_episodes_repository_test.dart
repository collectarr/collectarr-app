import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_custom_episode_codecs.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV custom episode sync payload is owned by the TV codec', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = CustomEpisodesRepository(
      db,
      codecs: collectarrCustomEpisodeCodecs,
    );
    final episode = CustomEpisode(
      id: 'tv-custom-1',
      seriesRef: const CatalogEntityRef(
        kind: 'tv',
        entityType: CatalogEntityType.work,
        id: 'tv-series-1',
      ),
      seasonNumber: 2,
      episodeNumber: 4,
      title: 'The Missing Cut',
      overview: 'A locally authored episode',
      airDate: '2026-05-20',
      runtimeMinutes: 47,
      stillImageUrl: 'https://cdn.example/still.jpg',
      localImagePath: 'covers/still.jpg',
      thumbnailImageUrl: 'https://cdn.example/thumb.jpg',
      updatedAt: DateTime.utc(2026, 5, 21),
    );

    final payload = repository.toSyncPayload(episode);
    final codec = collectarrCustomEpisodeCodecs.singleWhere(
      (candidate) => candidate.kind == 'tv',
    );
    final decoded = codec.fromSyncPayload(
      payload: payload,
      id: episode.id,
      updatedAt: episode.updatedAt,
    );

    expect(payload['season_number'], 2);
    expect(payload['episode_number'], 4);
    expect(payload['still_image_url'], episode.stillImageUrl);
    expect(decoded.seriesRef.toJson(), episode.seriesRef.toJson());
    expect(decoded.seasonNumber, 2);
    expect(decoded.episodeNumber, 4);
    expect(decoded.runtimeMinutes, 47);
    expect(decoded.localImagePath, episode.localImagePath);
  });

  test('unregistered custom episode kinds are rejected', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = CustomEpisodesRepository(
      db,
      codecs: collectarrCustomEpisodeCodecs,
    );
    final episode = CustomEpisode(
      id: 'movie-custom-1',
      seriesRef: const CatalogEntityRef(
        kind: 'movie',
        entityType: CatalogEntityType.work,
        id: 'movie-1',
      ),
      seasonNumber: 1,
      episodeNumber: 1,
      title: 'Unsupported payload',
      updatedAt: DateTime.utc(2026, 5, 21),
    );

    expect(
      () => repository.toSyncPayload(episode),
      throwsStateError,
    );
  });
}
