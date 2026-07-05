import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('maps media tracking status aliases from storage strings', () {
    expect(
      mediaTrackingStatusFromString('backlog'),
      MediaTrackingStatus.planned,
    );
    expect(
      mediaTrackingStatusFromString('reading'),
      MediaTrackingStatus.inProgress,
    );
    expect(
      mediaTrackingStatusFromString('watched'),
      MediaTrackingStatus.completed,
    );
    expect(
      mediaTrackingStatusFromString('replaying'),
      MediaTrackingStatus.repeating,
    );
  });

  test('owned item exposes reusable media tracking view', () {
    final item = testOwnedItem(
      id: 'owned-1',
      itemId: 'comic-1',
      rating: 5,
      readStatus: 'Read',
      personalNotes: 'Great issue.',
      purchaseDate: DateTime.utc(2026, 5, 12),
      updatedAt: DateTime.utc(2026, 5, 13),
    );

    final tracking = item.mediaTracking;

    expect(tracking.status, MediaTrackingStatus.completed);
    expect(tracking.statusLabel, 'Completed');
    expect(tracking.rating, 5);
    expect(tracking.notes, 'Great issue.');
    expect(tracking.completedAt, DateTime.utc(2026, 5, 12));
    expect(tracking.lastActivityAt, DateTime.utc(2026, 5, 13));
  });

  test('calculates progress ratio for tracked media', () {
    const tracking = MediaTracking(
      status: MediaTrackingStatus.inProgress,
      progressCurrent: 7,
      progressTotal: 10,
    );

    expect(tracking.hasProgress, isTrue);
    expect(tracking.progressRatio, 0.7);
  });
}
