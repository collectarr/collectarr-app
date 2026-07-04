import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book game and boardgame domain files do not keep catalog bridges', () async {
    const files = <String>[
      'lib/features/library/kinds/book/book_domain.dart',
      'lib/features/library/kinds/book/workspace_entry_builder.dart',
      'lib/features/library/kinds/game/game_domain.dart',
      'lib/features/library/kinds/game/workspace_entry_builder.dart',
      'lib/features/library/kinds/boardgame/boardgame_domain.dart',
      'lib/features/library/kinds/boardgame/workspace_entry_builder.dart',
    ];

    const banned = <String>[
      'core/models/catalog_item.dart',
      'fromCatalogItem',
      'fromLibraryMetadataItem',
      'fromCatalogEdition',
    ];

    for (final path in files) {
      final content = await File(path).readAsString();
      for (final pattern in banned) {
        expect(
          content.contains(pattern),
          isFalse,
          reason: '$path still contains $pattern',
        );
      }
    }
  });

  test('release builders do not depend on request.edition', () async {
    const files = <String>[
      'lib/features/library/kinds/book/workspace_entry_builder.dart',
      'lib/features/library/kinds/game/workspace_entry_builder.dart',
      'lib/features/library/kinds/boardgame/workspace_entry_builder.dart',
    ];

    for (final path in files) {
      final content = await File(path).readAsString();
      expect(
        content.contains('request.edition'),
        isFalse,
        reason: '$path still uses request.edition',
      );
    }
  });

  test('OwnedItem no longer accepts itemId in its constructor', () async {
    final content = await File('lib/core/models/owned_item.dart').readAsString();
    expect(content.contains('String? itemId'), isFalse);
  });
}
