import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(DeviceIdentity.resetForTesting);

  test('returns one stable id for concurrent getOrCreate calls', () async {
    SharedPreferences.setMockInitialValues({});
    DeviceIdentity.resetForTesting();
    final identity = DeviceIdentity();

    final ids = await Future.wait([
      identity.getOrCreate(),
      identity.getOrCreate(),
      identity.getOrCreate(),
    ]);

    expect(ids.toSet(), hasLength(1));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('collectarr.device_id'), ids.first);
  });
}
