import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps only universal personal tracking fields', () {
    final tracking = PersonalTrackingBase(
      status: MediaTrackingStatus.inProgress,
      rating: 8,
      startedAt: DateTime.utc(2026, 1, 2),
      completedAt: DateTime.utc(2026, 1, 3),
      notes: 'Second pass',
    );

    expect(tracking.status, MediaTrackingStatus.inProgress);
    expect(tracking.statusStorageValue, 'In progress');
    expect(tracking.rating, 8);
    expect(tracking.startedAt, DateTime.utc(2026, 1, 2));
    expect(tracking.completedAt, DateTime.utc(2026, 1, 3));
    expect(tracking.notes, 'Second pass');
  });

  test('TrackingEntry exposes completedAt through legacy finishedAt', () {
    final entry = TrackingEntry(
      id: 'tracking-1',
      catalogRef: const CatalogEntityRef(
        id: 'movie-1',
        kind: 'movie',
        entityType: CatalogEntityType.work,
      ),
      finishedAt: DateTime.utc(2026, 2, 3),
      updatedAt: DateTime.utc(2026, 2, 4),
    );

    expect(entry.completedAt, DateTime.utc(2026, 2, 3));
    expect(entry.finishedAt, entry.completedAt);
  });
}
