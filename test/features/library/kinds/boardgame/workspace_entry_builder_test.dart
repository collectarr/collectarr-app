import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('boardgame workspace entry stays domain-first and avoids raw platforms',
      () {
    final item = CatalogItem(
      id: 'boardgame-1',
      kind: 'boardgame',
      title: 'Example Board Game',
      editions: [
        CatalogEdition(
          id: 'edition-1',
          title: 'Core Box',
          format: 'Deluxe',
        ),
      ],
      genres: ['strategy'],
    );

    final entry = buildBoardGamesLibraryWorkspaceEntryFromShelf(
      ShelfEntry(itemId: 'boardgame-1', catalogItem: item),
    );

    expect(entry, isA<BoardGameWorkspaceEntry>());
    expect(entry.rawPlatforms, isNull);
    expect(entry.editions, isEmpty);
    expect(entry.referenceFormatLabel, 'Deluxe');
  });
}
