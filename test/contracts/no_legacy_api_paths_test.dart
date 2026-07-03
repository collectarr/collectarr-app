import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app api sources do not use legacy metadata item paths', () async {
    final apiDir = Directory('lib/core/api');
    final files = await apiDir
        .list(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dart'))
        .cast<File>()
        .toList();

    final legacyPatterns = <String>[
      '/metadata/items/',
      '/metadata/\$kind/',
    ];

    for (final file in files) {
      final content = await file.readAsString();
      for (final pattern in legacyPatterns) {
        expect(
          content.contains(pattern),
          isFalse,
          reason: '${file.path} still contains $pattern',
        );
      }
    }
  });
}
