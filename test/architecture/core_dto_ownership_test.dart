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
      if (!relativePath.contains('/data/remote/')) {
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
