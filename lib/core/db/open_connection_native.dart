import 'dart:io';

import 'package:collectarr_app/core/platform/app_data_directory_native.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await appDataDirectory();
    final file = File(p.join(dir.path, 'collectarr-library.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
