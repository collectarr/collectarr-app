import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

import 'contract_test_helpers.dart';

void defineTrackingProfileContract({
  required String name,
  required MediaTrackingProfile Function() create,
}) {
  defineTypedContract<MediaTrackingProfile>(
    name: '$name tracking profile contract',
    create: create,
    checks: [
      (profile) {
        expectNonEmpty(profile.name, '$name tracking needs a name');
        expectContract(
          profile.options.length == MediaTrackingStatus.values.length,
          '$name tracking must expose every status',
        );
        expectUnique(
          profile.options.map((option) => option.status.name),
          '$name tracking statuses must be unique',
        );
        expectSame(
          profile.options.map((option) => option.status).toSet(),
          MediaTrackingStatus.values.toSet(),
          '$name tracking must cover the shared status enum',
        );
        expectUnique(
          profile.options.map((option) => option.storageValue),
          '$name tracking storage values must be unique',
        );
        for (final option in profile.options) {
          expectNonEmpty(
            option.label,
            '$name tracking labels must not be empty',
          );
          if (option.status != MediaTrackingStatus.none) {
            expectSame(
              profile.normalizeStorageValue(option.storageValue),
              option.storageValue,
              '$name tracking storage values must normalize',
            );
            expectSame(
              profile.normalizeStorageValue(option.label),
              option.storageValue,
              '$name tracking labels must normalize',
            );
          }
        }
        expect(
          profile.normalizeStorageValue(''),
          isNull,
          reason: '$name untracked value should remain empty',
        );
      },
    ],
  );
}
