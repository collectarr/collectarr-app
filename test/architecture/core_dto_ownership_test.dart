import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated Core DTO imports stay in kind remote adapters', () {
    final violations = <String>[];
    final kindsRoot = Directory('lib/features/library/kinds');

    for (final entity in kindsRoot.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final relativePath = entity.path.replaceAll('\\', '/');
      final source = entity.readAsStringSync();
      if (!source.contains(
        'package:collectarr_app/core/api/generated/collectarr_api.models.dart',
      )) {
        continue;
      }
      // The registry is a composition root: it wires the kind-owned remote
      // mappers into the local catalog repository codec list. It may import
      // the generated DTO library for that wiring, but it must not interpret
      // a DTO or own a mapper implementation.
      final isKindCompositionRoot = relativePath.contains('/kinds/registry/');
      if (!relativePath.contains('/data/remote/') && !isKindCompositionRoot) {
        violations.add(relativePath);
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Generated Core DTOs are transport types and may only enter a kind '
          'through its data/remote adapter.',
    );
  });
}
