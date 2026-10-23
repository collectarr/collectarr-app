import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Reads installed build metadata without starting an update check.
final installedAppVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  final version = info.version.trim();
  if (version.isEmpty) throw StateError('Installed version is unavailable');
  final build = info.buildNumber.trim();
  return build.isEmpty ? version : '$version+$build';
});
