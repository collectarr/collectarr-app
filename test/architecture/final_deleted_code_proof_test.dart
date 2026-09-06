import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('removed typed-kind names stay out of production', () {
    const removedNames = [
      'LibraryMetadataItem',
      'LibraryCatalogItemView',
      'LibraryKindMetadataRuntime',
      'CatalogKindCodec',
      'KindEditDraft',
      'LibrarySectionRegistry',
      'DefaultLibraryEditPresentationBuilder',
      'CatalogCache',
    ];

    final violations = <String>[];
    for (final file in _productionDartFiles()) {
      final path = _normalized(file.path);
      final source = file.readAsStringSync();
      for (final name in removedNames) {
        if (RegExp(r'\b' + RegExp.escape(name) + r'\b').hasMatch(source)) {
          violations.add('$path: $name');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Removed catalog, edit, section, and cache names must not '
          'return to production code.',
    );
  });
}

Iterable<File> _productionDartFiles() sync* {
  for (final root in const ['lib/core', 'lib/features', 'lib/ui']) {
    for (final entity in Directory(root).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.g.dart')) continue;
      yield entity;
    }
  }
}

String _normalized(String path) => path.replaceAll('\\', '/');
