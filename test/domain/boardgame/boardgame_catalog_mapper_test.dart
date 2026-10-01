import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps one flat Board Game Catalog Item with edition details', () {
    final dto = CatalogItemDto.raw(
      id: 'boardgame-edition-1',
      mediaKind: CatalogMediaKind.boardgame,
      common: CatalogCommonDto(
        title: 'Brass: Birmingham — Deluxe Edition',
        originalTitle: 'Brass: Birmingham',
        synopsis: 'An economic strategy game.',
        releaseDate: DateTime.utc(2018, 10, 1),
        releaseYear: 2018,
      ),
      payload: const {
        'edition_title': 'Deluxe Edition',
        'barcode': '123456789',
        'catalog_number': 'ROX-001',
        'country': 'US',
        'language': 'en',
        'physical_format': 'boxed',
        'platforms': ['Tabletop'],
        'identifiers': ['bgg:224517'],
        'contributors': ['Martin Wallace'],
        'mechanics': ['Hand Management'],
        'categories': ['Economic'],
        'families': ['Brass'],
        'expansions': ['Brass: Birmingham — Deluxe'],
        'rankings': ['1'],
        'search_aliases': ['Brass Birmingham'],
        'original_language': 'en',
        'subtitle': 'Industrial Revolution',
        'min_players': 2,
        'max_players': 4,
        'recommended_players': '2-4',
        'best_players': '3-4',
        'playing_time_minutes': 120,
        'min_playtime_minutes': 60,
        'max_playtime_minutes': 120,
        'minimum_age': 14,
        'complexity_weight': 3.9,
        'designers': ['Martin Wallace'],
        'artists': ['Lina Cossette'],
        'publishers': ['Roxley'],
        'languages': ['English'],
        'bgg_rank': 1,
        'bgg_rating': 8.6,
        'bgg_rating_count': 45000,
      },
    );

    final mapped = BoardGameCatalogMapper.mapDtoToBoardGame(dto);

    expect(mapped.id, 'boardgame-edition-1');
    expect(mapped.title, 'Brass: Birmingham — Deluxe Edition');
    expect(mapped.originalTitle, 'Brass: Birmingham');
    expect(mapped.releaseDate, DateTime.utc(2018, 10, 1));
    expect(mapped.releaseYear, 2018);
    expect(mapped.metadata.rawPayload['edition_title'], 'Deluxe Edition');
    expect(mapped.metadata.originalTitle, 'Brass: Birmingham');
    expect(mapped.metadata.mechanics, ['Hand Management']);
    expect(mapped.metadata.categories, ['Economic']);
    expect(mapped.metadata.families, ['Brass']);
    expect(mapped.metadata.expansions, ['Brass: Birmingham — Deluxe']);
    expect(mapped.metadata.minPlayers, 2);
    expect(mapped.metadata.maxPlayers, 4);
    expect(mapped.metadata.recommendedPlayers, '2-4');
    expect(mapped.metadata.bestPlayers, '3-4');
    expect(mapped.metadata.bggRank, 1);
    expect(mapped.metadata.bggRating, 8.6);
    expect(mapped.metadata.bggRatingCount, 45000);
    expect(mapped.barcode, '123456789');
    expect(mapped.publisher, 'Roxley');
    expect(mapped.country, 'US');
    expect(mapped.language, 'English');
    expect(mapped.format, 'boxed');
  });
}
