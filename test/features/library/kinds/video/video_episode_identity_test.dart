import 'package:collectarr_app/features/library/kinds/video/video_episode_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('video episode identity formats SxxExx codes', () {
    const identity = VideoEpisodeIdentity(
      seasonNumber: 2,
      episodeNumber: 5,
      title: 'Test',
    );

    expect(identity.code, 'S02E05');
  });
}
