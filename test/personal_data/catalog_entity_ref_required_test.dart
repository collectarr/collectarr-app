import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('personal models anchor on catalogRef and derive itemId', () {
    final files = <String>[
      'lib/features/library/kinds/comic/domain/comic_owned_item.dart',
      'lib/core/models/wishlist_item.dart',
      'lib/features/library/tracking/tracking_storage_record.dart',
    ];

    for (final path in files) {
      final content = File(path).readAsStringSync();
      expect(
        content,
        anyOf(
          contains('CatalogEntityRef? catalogRef'),
          contains('CatalogEntityRef get catalogRef;'),
        ),
      );
      expect(
        content,
        anyOf(
          contains('String get itemId => catalogRef.id;'),
          contains('String get itemId => catalogRef.rootId ?? catalogRef.id;'),
        ),
      );
    }
  });
}
