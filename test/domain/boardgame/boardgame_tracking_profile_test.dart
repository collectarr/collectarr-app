import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_components.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BoardGame tracking contributor uses its own vocabulary', () {
    expect(boardGameKindTrackingProfile, boardGameTrackingProfile);
    expect(boardGameKindTrackingProfile.name, 'Board Games');
    expect(
      boardGameKindTrackingProfile.normalizeStorageValue('Played'),
      'Played',
    );
    expect(
      boardGameKindTrackingProfile.normalizeStorageValue('Want to play'),
      'Want to play',
    );
    expect(
      boardGameKindTrackingProfile.normalizeStorageValue('Replay'),
      'Replay',
    );
    expect(
      boardGameKindTrackingProfile.normalizeStorageValue('Completed'),
      'Played',
    );
    expect(
      boardGameKindTrackingProfile.normalizeStorageValue('Replaying'),
      'Replay',
    );
  });
}
