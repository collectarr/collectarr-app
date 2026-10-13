import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../tool/architecture/architecture_checker.dart';

void main() {
  test(
      'taxonomy allows runner config and rejects misplaced tests and benchmarks',
      () {
    final root =
        Directory.systemTemp.createTempSync('collectarr-test-taxonomy-');
    final tests = Directory(p.join(root.path, 'test'))..createSync();
    final config = File(p.join(tests.path, 'flutter_test_config.dart'))
      ..writeAsStringSync('');
    final stray = File(p.join(tests.path, 'widget_test.dart'));
    final feature = Directory(p.join(tests.path, 'features'));
    final helpers = File(p.join(feature.path, 'helpers.dart'));
    final benchmark =
        File(p.join(feature.path, 'workspace_benchmark_test.dart'));
    try {
      expect(testLayoutViolations(root.path), isEmpty);
      stray.writeAsStringSync('');
      feature.createSync();
      helpers.writeAsStringSync('');
      benchmark.writeAsStringSync('');
      expect(testLayoutViolations(root.path), contains(startsWith('TX001')));
      expect(testLayoutViolations(root.path), contains(startsWith('TX002')));
      expect(testLayoutViolations(root.path), contains(startsWith('TX003')));
    } finally {
      for (final file in [config, stray, helpers, benchmark]) {
        if (file.existsSync()) file.deleteSync();
      }
      if (feature.existsSync()) feature.deleteSync();
      tests.deleteSync();
      root.deleteSync();
    }
  });
}
