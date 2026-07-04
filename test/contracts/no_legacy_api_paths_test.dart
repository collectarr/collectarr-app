import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Future<List<File>> _dartFiles(String path) async {
  final dir = Directory(path);
  return dir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
}

void main() {
  test('app api sources do not use legacy metadata item paths', () async {
    final apiFiles = await _dartFiles('lib/core/api');
    final generatedFiles = await _dartFiles('lib/core/api/generated');
    final files = [...apiFiles, ...generatedFiles];

    final legacyPatterns = <String>[
      '/metadata/items/',
      '/metadata/comic/',
      '/metadata/\$kind/',
      'Future<CatalogEdition> createBookEdition',
      'Future<CatalogEdition> createBoardGameEdition',
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

    final client = await File('lib/core/api/generated/collectarr_api.client.dart')
        .readAsString();
    expect(client, contains('Future<BookEditionDto> createBookEdition'));
    expect(client, contains('Future<BoardGameEditionDto> createBoardGameEdition'));
    expect(client, isNot(contains('Future<CatalogEdition> createBookEdition')));
    expect(
      client,
      isNot(contains('Future<CatalogEdition> createBoardGameEdition')),
    );
  });

  test('book game and boardgame domain files do not import CatalogItem', () async {
    const files = <String>[
      'lib/features/library/kinds/book/book_domain.dart',
      'lib/features/library/kinds/game/game_domain.dart',
      'lib/features/library/kinds/game/workspace_entry_builder.dart',
      'lib/features/library/kinds/boardgame/boardgame_domain.dart',
      'lib/features/library/kinds/boardgame/workspace_entry_builder.dart',
    ];

    for (final path in files) {
      final content = await File(path).readAsString();
      expect(
        content,
        isNot(contains("core/models/catalog_item.dart")),
        reason: '$path still imports CatalogItem',
      );
    }
  });
}
