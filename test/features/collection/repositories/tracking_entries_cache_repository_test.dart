import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV codec reconstructs hierarchy coordinates from sync payload', () {
    final codec = collectarrTrackingEntryCodecs.singleWhere(
      (candidate) => candidate.kind == 'tv',
    );
    final updatedAt = DateTime.utc(2026, 9, 6, 12);
    final entry = TrackingEntry(
      id: 'tv-sync-1',
      catalogRef: const CatalogEntityRef(
        kind: 'tv',
        entityType: CatalogEntityType.work,
        id: 'tv-1',
      ),
      seasonNumber: 3,
      episodeNumber: 7,
      episodeRatings: const {'3:7': 10},
      updatedAt: updatedAt,
    );

    final restored = codec.fromSyncPayload(
      payload: codec.toSyncPayload(entry),
      id: entry.id,
      updatedAt: updatedAt,
    );
    expect(restored.catalogRef.entityType, CatalogEntityType.episode);
    expect(restored.seasonNumber, 3);
    expect(restored.episodeNumber, 7);
    expect(restored.episodeRatings, {'3:7': 10});
  });

  test('round-trips TV tracking coordinates through the TV codec', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingEntriesCacheRepository(
      db,
      codecs: collectarrTrackingEntryCodecs,
    );

    await repository.upsert(
      TrackingEntry(
        id: 'tv-tracking-1',
        catalogRef: const CatalogEntityRef(
          kind: 'tv',
          entityType: CatalogEntityType.work,
          id: 'tv-1',
        ),
        seasonNumber: 2,
        episodeNumber: 4,
        episodeRatings: const {'2:4': 9},
        updatedAt: DateTime.utc(2026, 9, 6),
      ),
    );

    final entry = await repository.findById('tv-tracking-1');
    expect(entry?.catalogRef.entityType, CatalogEntityType.episode);
    expect(entry?.seasonNumber, 2);
    expect(entry?.episodeNumber, 4);
    expect(entry?.episodeRatings, {'2:4': 9});
    expect(
      repository.toSyncPayload(entry!),
      containsPair('episode_ratings', {'2:4': 9}),
    );
    expect(repository.toSyncPayload(entry), containsPair('season_number', 2));
  });

  test('does not persist hierarchy coordinates for an unregistered kind',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = TrackingEntriesCacheRepository(
      db,
      codecs: collectarrTrackingEntryCodecs,
    );

    await repository.upsert(
      TrackingEntry(
        id: 'movie-tracking-1',
        catalogRef: const CatalogEntityRef(
          kind: 'movie',
          entityType: CatalogEntityType.work,
          id: 'movie-1',
        ),
        seasonNumber: 99,
        episodeNumber: 1,
        episodeRatings: const {'99:1': 10},
        updatedAt: DateTime.utc(2026, 9, 6),
      ),
    );

    final entry = await repository.findById('movie-tracking-1');
    final row = await db.select(db.trackingEntriesCache).getSingle();
    expect(entry?.seasonNumber, isNull);
    expect(entry?.episodeNumber, isNull);
    expect(entry?.episodeRatings, isEmpty);
    expect(row.seasonNumber, isNull);
    expect(row.episodeNumber, isNull);
    expect(row.episodeRatings, isNull);
  });
}
