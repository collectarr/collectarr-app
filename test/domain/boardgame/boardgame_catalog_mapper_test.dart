import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves typed BoardGame work and edition catalog fields', () {
    final dto = CatalogItemDto.raw(
      id: 'boardgame-1',
      mediaKind: CatalogMediaKind.boardgame,
      common: CatalogCommonDto(
        title: 'Brass: Birmingham',
        originalTitle: 'Brass: Birmingham',
        synopsis: 'An economic strategy game.',
        releaseDate: DateTime.utc(2018, 10, 1),
        releaseYear: 2018,
        editions: [
          CatalogEditionDto(
            id: 'edition-1',
            title: 'Deluxe Edition',
            publisher: 'Roxley',
            upc: '123456789',
            language: 'en',
            region: 'US',
            releaseDate: DateTime.utc(2018, 10, 1),
            format: 'boxed',
            metadata: const {
              'title_value': 'Brass: Birmingham',
              'work_id': 'boardgame-1',
              'edition_title': 'Deluxe Edition',
              'age_rating': '12+',
              'audience_rating': 'Family',
              'catalog_number': 'ROX-001',
              'cover_image_url': 'https://example.com/brass.jpg',
              'description': 'Deluxe components.',
              'max_players': 4,
              'min_age': 14,
              'min_players': 2,
              'playing_time_minutes': 120,
              'release_status': 'published',
            },
          ),
        ],
      ),
      payload: const {
        'platforms': ['Tabletop'],
        'identifiers': ['bgg:224517'],
        'contributors': ['Martin Wallace'],
        'mechanics': ['Hand Management'],
        'categories': ['Economic'],
        'families': ['Brass'],
        'expansions': ['Brass: Birmingham - Deluxe'],
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
        'min_age': 14,
        'complexity_weight': 3.9,
        'designers': ['Martin Wallace'],
        'artists': ['Lina Cossette'],
        'publishers': ['Roxley'],
        'languages': ['English'],
        'genres': ['Economic'],
        'board_game_stats': {
          'bgg_rank': 1,
          'bgg_rating': 8.6,
          'bgg_rating_count': 45000,
          'bgg_weight': 3.9,
        },
      },
    );

    final mapped = BoardGameCatalogMapper.mapDtoToBoardGame(dto);

    expect(mapped.work.title, 'Brass: Birmingham');
    expect(mapped.work.originalTitle, 'Brass: Birmingham');
    expect(mapped.work.releaseDate, DateTime.utc(2018, 10, 1));
    expect(mapped.work.yearPublished, 2018);
    expect(mapped.work.originalLanguage, 'en');
    expect(mapped.work.subtitle, 'Industrial Revolution');
    expect(mapped.work.platforms, ['Tabletop']);
    expect(mapped.work.identifiers, ['bgg:224517']);
    expect(mapped.work.contributors, ['Martin Wallace']);
    expect(mapped.work.mechanics, ['Hand Management']);
    expect(mapped.work.categories, ['Economic']);
    expect(mapped.work.families, ['Brass']);
    expect(mapped.work.expansions, ['Brass: Birmingham - Deluxe']);
    expect(mapped.work.rankings, ['1']);
    expect(mapped.work.searchAliases, ['Brass Birmingham']);
    expect(mapped.work.minPlayers, 2);
    expect(mapped.work.maxPlayers, 4);
    expect(mapped.work.recommendedPlayers, '2-4');
    expect(mapped.work.bestPlayers, '3-4');
    expect(mapped.work.playingTimeMinutes, 120);
    expect(mapped.work.minPlaytimeMinutes, 60);
    expect(mapped.work.maxPlaytimeMinutes, 120);
    expect(mapped.work.minAge, 14);
    expect(mapped.work.complexityWeight, 3.9);
    expect(mapped.work.designers, ['Martin Wallace']);
    expect(mapped.work.artists, ['Lina Cossette']);
    expect(mapped.work.publishers, ['Roxley']);
    expect(mapped.work.languages, ['English']);
    expect(mapped.stats.bggRank, 1);
    expect(mapped.stats.bggRating, 8.6);
    expect(mapped.stats.bggRatingCount, 45000);
    expect(mapped.stats.bggWeight, 3.9);

    final edition = mapped.editions.single;
    expect(edition.id, 'edition-1');
    expect(edition.title, 'Deluxe Edition');
    expect(edition.titleValue, 'Brass: Birmingham');
    expect(edition.workId, 'boardgame-1');
    expect(edition.editionTitle, 'Deluxe Edition');
    expect(edition.ageRating, '12+');
    expect(edition.audienceRating, 'Family');
    expect(edition.barcode, '123456789');
    expect(edition.catalogNumber, 'ROX-001');
    expect(edition.country, 'US');
    expect(edition.coverImageUrl, 'https://example.com/brass.jpg');
    expect(edition.description, 'Deluxe components.');
    expect(edition.format, 'boxed');
    expect(edition.language, 'en');
    expect(edition.maxPlayers, 4);
    expect(edition.minAge, 14);
    expect(edition.minPlayers, 2);
    expect(edition.playingTimeMinutes, 120);
    expect(edition.publisher, 'Roxley');
    expect(edition.releaseDate, DateTime.utc(2018, 10, 1));
    expect(edition.releaseStatus, 'published');
    expect(edition.rawPayload['catalog_number'], 'ROX-001');
  });
}
