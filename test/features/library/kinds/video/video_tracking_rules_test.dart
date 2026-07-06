import 'package:collectarr_app/features/library/kinds/video/video_tracking_rules.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('completed released episodes with future episodes is caught up', () {
    final result = deriveVideoTrackingRuleResult(
      releasedEpisodes: 10,
      watchedEpisodes: 10,
      hasUnairedEpisodes: true,
    );

    expect(result.status, MediaTrackingStatus.completed);
    expect(result.statusLabel, 'Caught up');
    expect(result.shouldMarkCompleted, isFalse);
    expect(result.shouldMarkCaughtUp, isTrue);
  });

  test('all released episodes watched is completed', () {
    final result = deriveVideoTrackingRuleResult(
      releasedEpisodes: 10,
      watchedEpisodes: 10,
      hasUnairedEpisodes: false,
    );

    expect(result.status, MediaTrackingStatus.completed);
    expect(result.statusLabel, 'Watched');
    expect(result.shouldMarkCompleted, isTrue);
  });
}
