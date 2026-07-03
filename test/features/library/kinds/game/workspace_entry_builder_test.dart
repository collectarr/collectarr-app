import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace_entry_builder.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('game workspace entry uses domain releases and no raw platforms', () {
    final item = CatalogItem(
      id: 'game-1',
      kind: 'game',
      title: 'Example Game',
      game: const GameCatalogDetails(platforms: ['Switch']),
      editions: [
        CatalogEdition(
          id: 'release-1',
          title: 'Standard',
          format: 'Physical',
        ),
      ],
    );

    final entry = buildGamesLibraryWorkspaceEntryFromShelf(
      ShelfEntry(itemId: 'game-1', catalogItem: item),
    );

    expect(entry, isA<GameWorkspaceEntry>());
    expect(entry.game?.platforms, ['Switch']);
    expect(entry.rawPlatforms, isNull);
    expect(entry.referenceFormatLabel, 'Physical');
  });
}
