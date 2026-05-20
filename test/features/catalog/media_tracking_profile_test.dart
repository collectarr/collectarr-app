import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes comic tracking aliases to comic labels', () {
    expect(
        comicTrackingProfile.normalizeStorageValue('planned'), 'Plan to read');
    expect(comicTrackingProfile.normalizeStorageValue('reading'), 'Reading');
    expect(comicTrackingProfile.normalizeStorageValue('completed'), 'Read');
    expect(
        comicTrackingProfile.normalizeStorageValue('rereading'), 'Rereading');
  });

  test('keeps media-specific tracking vocabulary reusable', () {
    expect(gameTrackingProfile.normalizeStorageValue('planned'), 'Backlog');
    expect(gameTrackingProfile.normalizeStorageValue('playing'), 'Playing');
    expect(
        videoTrackingProfile.normalizeStorageValue('planned'), 'Plan to watch');
    expect(videoTrackingProfile.normalizeStorageValue('watched'), 'Watched');
  });
}
