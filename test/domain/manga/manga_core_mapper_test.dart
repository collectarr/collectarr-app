import 'dart:io';

import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_domain.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/core_field_adoption_contract.dart';
import '../../contracts/core_mapping_contract.dart';

void main() {
  test('MangaWorkDto maps directly into MangaMedia', () {
    final dto = MangaWorkDto.fromJson({
      'id': 'manga-1',
      'kind': 'manga',
      'title': 'Vagabond',
      'sort_title': 'Vagabond',
      'description': 'A wandering swordsman searches for meaning.',
      'first_publication_date': '1998-09-03T00:00:00Z',
      'original_language': 'ja',
      'original_publication_date': '1998-09-03T00:00:00Z',
      'status': 'hiatus',
      'subtitle': 'The Definitive Edition',
      'chapters': [
        {'id': 'chapter-1', 'number': 1, 'title': 'The Invincible'},
      ],
      'character_appearances': [
        {'name': 'Miyamoto Musashi', 'role': 'protagonist'},
      ],
      'contributions': [
        {'name': 'Takehiko Inoue', 'role': 'author'},
      ],
      'identifiers': [
        {'type': 'isbn', 'value': '978-1569317075'},
      ],
      'series': [
        {'id': 'series-vagabond', 'title': 'Vagabond'},
      ],
    });

    final media = MangaCoreMapper.fromWorkDto(dto);

    expect(media.id, 'manga-1');
    expect(media.title, 'Vagabond');
    expect(media.sortTitle, 'Vagabond');
    expect(media.description, 'A wandering swordsman searches for meaning.');
    expect(media.firstPublicationDate, DateTime.utc(1998, 9, 3));
    expect(media.originalLanguage, 'ja');
    expect(media.originalPublicationDate, DateTime.utc(1998, 9, 3));
    expect(media.status, 'hiatus');
    expect(media.subtitle, 'The Definitive Edition');
    final chapter = media.chapters.single as Map<String, dynamic>;
    final character = media.characterAppearances.single as Map<String, dynamic>;
    final contribution = media.contributions.single as Map<String, dynamic>;
    final identifier = media.identifiers.single as Map<String, dynamic>;
    final series = media.series.single as Map<String, dynamic>;
    expect(chapter['number'], 1);
    expect(character['name'], 'Miyamoto Musashi');
    expect(contribution['role'], 'author');
    expect(identifier['value'], '978-1569317075');
    expect(series['id'], 'series-vagabond');
  });

  test('Manga mapper rejects a DTO with the wrong kind', () {
    final dto = MangaWorkDto.fromJson({
      'id': 'not-manga',
      'kind': 'comic',
      'title': 'Wrong kind',
    });

    expect(
      () => MangaCoreMapper.fromWorkDto(dto),
      throwsA(isA<StateError>()),
    );
  });

  test('Manga remote source maps a fetched Core DTO', () async {
    final source = ApiMangaRemoteSource((id) async {
      expect(id, 'manga-2');
      return MangaWorkDto.fromJson({
        'id': id,
        'kind': 'manga',
        'title': 'Nausicaa',
      });
    });

    final media = await source.fetchMedia('manga-2');

    expect(media.id, 'manga-2');
    expect(media.title, 'Nausicaa');
  });

  defineCoreMappingContract<MangaMedia, MangaWorkDto>(
    name: 'manga',
    createDomain: () => MangaMedia(
      id: 'manga-contract',
      title: 'Contract Manga',
      sortTitle: 'Contract Manga',
      description: 'Contract description',
      firstPublicationDate: DateTime.utc(2020, 1, 2),
      originalLanguage: 'ja',
      originalPublicationDate: DateTime.utc(2019, 12, 1),
      status: 'completed',
      subtitle: 'Volume 1',
      chapters: [
        {'id': 'chapter-contract', 'number': 1},
      ],
      characterAppearances: [
        {'name': 'Character'},
      ],
      contributions: [
        {'name': 'Creator', 'role': 'author'},
      ],
      identifiers: [
        {'type': 'isbn', 'value': 'contract-isbn'},
      ],
      series: [
        {'id': 'series-contract', 'title': 'Contract Series'},
      ],
    ),
    encode: (domain) => MangaWorkDto.fromJson(domain.toJson()),
    decode: MangaCoreMapper.fromWorkDto,
    equals: (left, right) =>
        left.id == right.id &&
        left.title == right.title &&
        left.sortTitle == right.sortTitle &&
        left.description == right.description &&
        left.firstPublicationDate == right.firstPublicationDate &&
        left.originalLanguage == right.originalLanguage &&
        left.originalPublicationDate == right.originalPublicationDate &&
        left.status == right.status &&
        left.subtitle == right.subtitle &&
        left.chapters.length == right.chapters.length &&
        left.characterAppearances.length == right.characterAppearances.length &&
        left.contributions.length == right.contributions.length &&
        left.identifiers.length == right.identifiers.length &&
        left.series.length == right.series.length,
  );

  test('MangaWorkDto fields are explicitly classified', () {
    final source = File(
      'lib/core/api/generated/collectarr_api.models.dart',
    ).readAsStringSync();
    validateCoreDtoFieldAdoption(
      source: source,
      policy: CoreFieldAdoptionPolicy(
        dtoName: 'MangaWorkDto',
        mapped: {
          'id',
          'title',
          'chapters',
          'characterAppearances',
          'contributions',
          'description',
          'firstPublicationDate',
          'identifiers',
          'originalLanguage',
          'originalPublicationDate',
          'series',
          'sortTitle',
          'status',
          'subtitle',
        },
        intentionallyIgnored: {
          'kind': 'used to validate the typed Manga DTO boundary',
        },
      ),
    );
  });
}
