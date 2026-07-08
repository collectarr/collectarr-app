import 'package:collectarr_app/features/updater/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isNewerVersion', () {
    test('orders beta prereleases correctly', () {
      expect(isNewerVersion('1.1.0-beta.1', '1.1.0-beta.2'), isTrue);
      expect(isNewerVersion('1.1.0-beta.2', '1.1.0-beta.10'), isTrue);
    });

    test('treats stable releases as newer than prereleases on the same core',
        () {
      expect(isNewerVersion('1.1.0-beta.10', '1.1.0'), isTrue);
      expect(isNewerVersion('1.1.0', '1.1.0-beta.10'), isFalse);
    });

    test('compares core semver before prerelease labels', () {
      expect(isNewerVersion('1.1.0-beta.1', '1.2.0-beta.1'), isTrue);
      expect(isNewerVersion('1.2.0-beta.1', '1.1.0-beta.1'), isFalse);
    });
  });
}
