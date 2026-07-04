import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('watch session sync payload uses catalog ref', () {
    final ref = CatalogEntityRef(
      kind: 'tv',
      entityType: CatalogEntityType.release,
      id: 'release-1',
    );
    final watchedAt = DateTime.utc(2026, 7, 5, 12, 30);
    final updatedAt = DateTime.utc(2026, 7, 5, 13, 0);
    final session = WatchSession(
      id: 'session-1',
      targetRef: ref,
      trackingEntryId: 'track-1',
      seasonNumber: 1,
      episodeNumber: 3,
      sourceType: TrackingSourceType.physical,
      seenWhere: 'Blu-ray player',
      watchedAt: watchedAt,
      rating: 9,
      notes: 'Excellent',
      updatedAt: updatedAt,
    );

    expect(session.itemId, 'release-1');
    expect(session.toSyncPayload(), {
      'catalog_ref': ref.toJson(),
      'tracking_entry_id': 'track-1',
      'season_number': 1,
      'episode_number': 3,
      'source_type': 'physical',
      'watched_at': watchedAt.toUtc().toIso8601String(),
      'seen_where': 'Blu-ray player',
      'rating': 9,
      'notes': 'Excellent',
    });

    final roundTrip = WatchSession.fromJson({
      'id': 'session-1',
      'catalog_ref': ref.toJson(),
      'tracking_entry_id': 'track-1',
      'season_number': 1,
      'episode_number': 3,
      'source_type': 'manual',
      'seen_where': 'Blu-ray player',
      'watched_at': watchedAt.toUtc().toIso8601String(),
      'rating': 9,
      'notes': 'Excellent',
      'updated_at': updatedAt.toUtc().toIso8601String(),
    });

    expect(roundTrip.targetRef.id, 'release-1');
    expect(roundTrip.targetRef.entityType, CatalogEntityType.release);
    expect(roundTrip.seenWhere, 'Blu-ray player');
    expect(roundTrip.rating, 9);
  });
}
