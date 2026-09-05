import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_tracking_rules.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('anime reports caught up while unreleased episodes remain', () {
    final result = deriveAnimeTrackingRuleResult(
      releasedEpisodes: 10,
      watchedEpisodes: 10,
      hasUnairedEpisodes: true,
    );

    expect(result.status, MediaTrackingStatus.completed);
    expect(result.statusLabel, 'Caught up');
    expect(result.shouldMarkCompleted, isFalse);
    expect(result.shouldMarkCaughtUp, isTrue);
  });
}
