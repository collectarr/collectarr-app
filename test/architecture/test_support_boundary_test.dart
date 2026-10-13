import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../tool/architecture/architecture_checker.dart';

void main() {
  for (final uri in [
    '../test/support/fixtures/example.dart',
    '../integration_test/example.dart',
    'package:collectarr_app/test/helpers/example.dart',
  ]) {
    test('production rejects test support import: $uri', () {
      final root = Directory.current.path;
      final path = p.join(root, 'lib', 'main.dart');
      final parsed = parseString(content: "import '$uri';", path: path);
      final visitor = ArchitectureRuleVisitor(
        filePath: path,
        relativePath: 'lib/main.dart',
        lineInfo: parsed.lineInfo,
        isBoundaryFile: false,
        isRegistryFile: false,
        kindName: null,
        repoRoot: root,
      );
      parsed.unit.accept(visitor);
      expect(visitor.violations, contains(startsWith('TK022')));
    });
  }

  test('production tree cannot contain a test directory', () {
    final root =
        Directory.systemTemp.createTempSync('collectarr-test-boundary-');
    final lib = Directory(p.join(root.path, 'lib'));
    final support = Directory(p.join(lib.path, 'test'));
    try {
      expect(testSupportLayoutViolations(root.path), isEmpty);
      support.createSync(recursive: true);
      expect(testSupportLayoutViolations(root.path),
          contains(startsWith('TK022')));
    } finally {
      if (support.existsSync()) support.deleteSync();
      if (lib.existsSync()) lib.deleteSync();
      root.deleteSync();
    }
  });
}
