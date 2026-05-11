import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceIdProvider = FutureProvider<String>((ref) {
  return DeviceIdentity().getOrCreate();
});

