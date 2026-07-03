import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('personal models anchor on catalogRef and derive itemId', () {
    final files = <String>[
      'lib/core/models/owned_item.dart',
      'lib/core/models/wishlist_item.dart',
      'lib/core/models/tracking_entry.dart',
    ];

    for (final path in files) {
      final content = File(path).readAsStringSync();
      expect(content, contains('CatalogEntityRef? catalogRef'));
      expect(content, contains('String get itemId => catalogRef.id;'));
    }
  });
}
