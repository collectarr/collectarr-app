import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/tracking/boardgame_tracking_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BoardGame module uses its own tracking vocabulary', () {
    expect(boardGameKindModule.trackingProfile, boardGameTrackingProfile);
    expect(boardGameKindModule.trackingProfile.name, 'Board Games');
    expect(
      boardGameKindModule.trackingProfile.normalizeStorageValue('Played'),
      'Played',
    );
    expect(
      boardGameKindModule.trackingProfile.normalizeStorageValue('Want to play'),
      'Want to play',
    );
    expect(
      boardGameKindModule.trackingProfile.normalizeStorageValue('Replay'),
      'Replay',
    );
    expect(
      boardGameKindModule.trackingProfile.normalizeStorageValue('Completed'),
      'Played',
    );
    expect(
      boardGameKindModule.trackingProfile.normalizeStorageValue('Replaying'),
      'Replay',
    );
  });
}
