import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/boardgame_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/stats/boardgame_stats_capability.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BoardGame stats summarize typed metadata', () {
    final entries = [
      _entry(
        'bg-1',
        const BoardGameMetadata(
          title: 'Brass: Birmingham',
          bggRating: 8.6,
          bggRank: 1,
          designers: ['Martin Wallace'],
          mechanics: ['Hand Management', 'Network Building'],
          categories: ['Economic'],
        ),
      ),
      _entry(
        'bg-2',
        const BoardGameMetadata(
          title: 'Brass: Lancashire',
          bggRating: 8.1,
          bggRank: 20,
          designers: ['Martin Wallace'],
          mechanics: ['Hand Management', 'Network Building'],
          categories: ['Economic', 'Industry'],
        ),
      ),
    ];

    expect(BoardGameStatsCapability.averageBggRating(entries), 8.35);
    expect(BoardGameStatsCapability.bestBggRank(entries), 1);
    expect(BoardGameStatsCapability.countMechanics(entries), {
      'Hand Management': 2,
      'Network Building': 2,
    });
    expect(BoardGameStatsCapability.countCategories(entries), {
      'Economic': 2,
      'Industry': 1,
    });
    expect(BoardGameStatsCapability.countDesigners(entries), {
      'Martin Wallace': 2,
    });
  });

  test('BoardGame module exposes typed stats capability', () {
    expect(boardGameKindModule.stats, isA<BoardGameStatsCapability>());
  });
}

ShelfEntry _entry(String id, BoardGameMetadata metadata) {
  return ShelfEntry(
    itemId: id,
    catalogItem: LibraryMetadataItem(
      identity: LibraryItemIdentity(
        id: id,
        mediaKind: CatalogMediaKind.boardgame,
      ),
      kindMetadata: metadata,
    ),
  );
}
