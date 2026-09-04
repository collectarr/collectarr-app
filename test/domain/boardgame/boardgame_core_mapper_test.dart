import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/remote/boardgame_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/remote/boardgame_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a BoardGame work DTO into the typed media model', () {
    final dto = BoardGameWorkDto.fromJson({
      'id': 'work-1',
      'kind': 'boardgame',
      'title': 'Brass: Birmingham',
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
      'publisher': 'Roxley',
      'release_date': '2018-10-01T00:00:00.000Z',
      'sort_title': 'Brass Birmingham',
      'subtitle': 'Industrial Revolution',
      'description': 'An economic strategy game.',
    });

    final media = BoardGameCoreMapper.fromWorkDto(dto);

    expect(media.id, const BoardGameMediaId('work-1'));
    expect(media.title, 'Brass: Birmingham');
    expect(media.platforms, ['Tabletop']);
    expect(media.identifiers, ['bgg:224517']);
    expect(media.contributors, ['Martin Wallace']);
    expect(media.mechanics, ['Hand Management']);
    expect(media.categories, ['Economic']);
    expect(media.families, ['Brass']);
    expect(media.expansions, ['Brass: Birmingham - Deluxe']);
    expect(media.rankings, ['1']);
    expect(media.searchAliases, ['Brass Birmingham']);
    expect(media.releaseDate, DateTime.utc(2018, 10, 1));
    expect(media.rawPayload['description'], 'An economic strategy game.');
    expect(media.editions, isEmpty);
  });

  test('maps every BoardGame edition field', () {
    final dto = BoardGameEditionDto.fromJson({
      'id': 'edition-1',
      'kind': 'boardgame',
      'work_id': 'work-1',
      'title': 'Brass: Birmingham',
      'edition_title': 'Deluxe Edition',
      'age_rating': '12+',
      'audience_rating': 'Family',
      'barcode': '123456789',
      'catalog_number': 'ROX-001',
      'country': 'US',
      'cover_image_url': 'https://example.com/brass.jpg',
      'description': 'Deluxe components.',
      'format': 'boxed',
      'language': 'en',
      'max_players': 4,
      'min_age': 14,
      'min_players': 2,
      'playing_time_minutes': 120,
      'publisher': 'Roxley',
      'release_date': '2018-10-01T00:00:00.000Z',
      'release_status': 'published',
    });

    final edition = BoardGameCoreMapper.fromEditionDto(dto);

    expect(edition.typedId, const BoardGameEditionId('edition-1'));
    expect(edition.title, 'Deluxe Edition');
    expect(edition.titleValue, 'Brass: Birmingham');
    expect(edition.workId, 'work-1');
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

  test('rejects Core DTOs for another kind', () {
    final dto = BoardGameWorkDto.fromJson({
      'id': 'wrong-kind',
      'kind': 'game',
      'title': 'Not a board game',
    });

    expect(
      () => BoardGameCoreMapper.fromWorkDto(dto),
      throwsA(isA<StateError>()),
    );
  });

  test('remote source fetches work and edition through typed endpoints',
      () async {
    var workId = '';
    var editionId = '';
    final remote = ApiBoardGameRemoteSource(
      (id) async {
        workId = id;
        return BoardGameWorkDto.fromJson({
          'id': id,
          'kind': 'boardgame',
          'title': 'Catan',
        });
      },
      (id) async {
        editionId = id;
        return BoardGameEditionDto.fromJson({
          'id': id,
          'kind': 'boardgame',
          'work_id': 'work-1',
          'title': 'Catan Edition',
        });
      },
    );

    final media = await remote.fetchMedia(const BoardGameMediaId('work-1'));
    final edition =
        await remote.fetchEdition(const BoardGameEditionId('edition-1'));

    expect(workId, 'work-1');
    expect(editionId, 'edition-1');
    expect(media.title, 'Catan');
    expect(edition.title, 'Catan Edition');
  });
}
