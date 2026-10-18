import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Folder holding the library database and its backups.
///
/// On Windows path_provider nests the product under the company name, which
/// are both "Collectarr", so the data lives directly in `%APPDATA%\Collectarr`.
Future<Directory> appDataDirectory() async {
  final roaming = Platform.isWindows ? Platform.environment['APPDATA'] : null;
  if (roaming == null || roaming.isEmpty) {
    return getApplicationSupportDirectory();
  }
  return Directory(p.join(roaming, 'Collectarr')).create(recursive: true);
}
