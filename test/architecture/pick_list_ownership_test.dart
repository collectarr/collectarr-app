import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production pick-list code uses the canonical pick_lists namespace', () {
    const legacyImports = [
      'package:collectarr_app/features/collection/pick_list/',
      'package:collectarr_app/features/collection/vocabulary/',
    ];
    final violations = <String>[];
    final lib = Directory('lib');
    for (final entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final source = entity.readAsStringSync();
      for (final legacyImport in legacyImports) {
        if (source.contains(legacyImport)) {
          violations.add('${entity.path}: $legacyImport');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Legacy pick-list/vocabulary namespaces must remain only as '
          'filesystem compatibility shims, never as production imports.',
    );
  });
}
