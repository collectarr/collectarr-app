import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../tool/architecture/architecture_checker.dart';

List<String> check(String source, String path, {bool shared = true}) {
  final parsed = parseString(content: source);
  final visitor = ArchitectureRuleVisitor(
      filePath: '${Directory.current.path}/$path',
      relativePath: path,
      lineInfo: parsed.lineInfo,
      isBoundaryFile: shared,
      isRegistryFile: false,
      kindName: shared ? null : 'comic',
      repoRoot: Directory.current.path,
      sourceContent: source);
  parsed.unit.accept(visitor);
  return visitor.violations;
}

void main() {
  for (final path in [
    'lib/features/library/workspace/tiles/card.dart',
    'lib/features/library/workspace/layout/flow_carousel.dart',
    'lib/features/library/selection/controls.dart',
    'lib/features/library/generic/toolbar/selection.dart',
    'lib/features/settings/settings_kind_section.dart'
  ]) {
    test('shared kind-name dispatch is rejected in $path', () {
      for (final expression in [
        "kind == 'comic'",
        "name.toLowerCase() == 'music'",
        "kind != 'game_hardware'"
      ]) {
        expect(
            check('bool test(String kind, String name) => $expression;', path)
                .where((v) => v.startsWith('TK005')),
            isNotEmpty);
      }
      expect(
          check("bool test(String id) => id == 'music.merge';", path)
              .where((v) => v.startsWith('TK005')),
          isEmpty);
      expect(
          check("import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';",
                  path)
              .where((v) => v.startsWith('TK001')),
          isNotEmpty);
    });
  }
  test('a kind may own its own comparisons', () {
    expect(
        check("bool test(String kind) => kind == 'comic';",
                'lib/features/library/kinds/comic/workspace/content.dart',
                shared: false)
            .where((v) => v.startsWith('TK005')),
        isEmpty);
  });
}
