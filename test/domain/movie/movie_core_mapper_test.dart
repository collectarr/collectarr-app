import 'dart:io';

import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/remote/movie_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/remote/movie_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/core_field_adoption_contract.dart';
import '../../contracts/core_mapping_contract.dart';

void main() {
  test('MovieWorkDto maps directly into MovieMedia and typed releases', () {
    final dto = MovieWorkDto.fromJson({
      'id': 'movie-1',
      'kind': 'movie',
      'title': 'The Matrix',
      'age_rating': 'R',
      'audience_rating': 'R',
      'character_appearances': [
        {
          'id': 'character-appearance-1',
          'character_id': 'character-1',
          'character_name': 'Neo',
          'role': 'protagonist',
        },
      ],
      'contributions': [
        {
          'id': 'contribution-1',
          'person_id': 'person-1',
          'name': 'Lana Wachowski',
          'role': 'director',
          'sequence': 1,
        },
      ],
      'description': 'A hacker discovers the nature of reality.',
      'external_links': [
        {'id': 'link-1', 'url': 'https://example.com/matrix'},
      ],
      'identifiers': [
        {
          'id': 'identifier-1',
          'identifier_type': 'tmdb',
          'value': '603',
          'is_primary': true,
        },
      ],
      'original_language': 'en',
      'release_date': '1999-03-31T00:00:00Z',
      'runtime_minutes': 136,
      'sort_title': 'Matrix, The',
      'subtitle': 'The One',
      'trailer_urls': [
        {
          'id': 'trailer-1',
          'url': 'https://example.com/trailer',
          'title': 'Official trailer',
        },
      ],
      'releases': [
        {
          'id': 'release-1',
          'work_id': 'movie-1',
          'release_title': '4K Collector Edition',
          'cover_image_url': 'https://example.com/release.jpg',
          'format': '4K UHD',
          'region': 'US',
          'release_date': '2018-05-22T00:00:00Z',
          'media': [
            {
              'id': 'media-1',
              'release_id': 'release-1',
              'media_number': 1,
              'media_type': 'disc',
              'num_discs': 2,
              'audio_tracks': 'Dolby Atmos',
              'subtitles': 'English, Spanish',
            },
          ],
        },
      ],
    });

    final media = MovieCoreMapper.fromWorkDto(dto);

    expect(media.id, const MovieMediaId('movie-1'));
    expect(media.title, 'The Matrix');
    expect(media.runtimeMinutes, 136);
    expect(media.contributions.single.personId, 'person-1');
    expect(media.characterAppearances.single.characterName, 'Neo');
    expect(media.identifiers.single.value, '603');
    expect(media.externalLinks.single.url, 'https://example.com/matrix');
    expect(media.trailerUrls.single.title, 'Official trailer');
    expect(media.releases, hasLength(1));
    expect(media.releases.single.typedId, const MovieReleaseId('release-1'));
    expect(media.releases.single.workId, 'movie-1');
    expect(media.releases.single.title, '4K Collector Edition');
    expect(media.releases.single.media.single.typedId,
        const MovieReleaseMediaId('media-1'));
    expect(media.releases.single.media.single.numDiscs, 2);
  });

  test('Movie release payload maps independently from MovieWorkDto', () {
    final release = MovieCoreMapper.fromReleasePayload({
      'id': 'release-2',
      'kind': 'movie',
      'work_id': 'movie-2',
      'release_title': 'Blu-ray Edition',
      'format': 'Blu-ray',
      'language': 'en',
      'region': 'EU',
    });

    expect(release.typedId, const MovieReleaseId('release-2'));
    expect(release.typedWorkId, const MovieMediaId('movie-2'));
    expect(release.title, 'Blu-ray Edition');
    expect(release.format, 'Blu-ray');
  });

  test('Movie mapper rejects a DTO with the wrong kind', () {
    final dto = MovieWorkDto.fromJson({
      'id': 'not-movie',
      'kind': 'book',
      'title': 'Wrong kind',
    });

    expect(
      () => MovieCoreMapper.fromWorkDto(dto),
      throwsA(isA<StateError>()),
    );
  });

  test('Movie remote source maps a work fetch', () async {
    final source = ApiMovieRemoteSource(
      (id) async => MovieWorkDto.fromJson({
        'id': id,
        'kind': 'movie',
        'title': 'The Secret Life of Walter Mitty',
      }),
    );

    final media = await source.fetchMedia(const MovieMediaId('movie-2'));

    expect(media.id, const MovieMediaId('movie-2'));
    expect(media.title, 'The Secret Life of Walter Mitty');
  });

  defineCoreMappingContract<MovieMedia, MovieWorkDto>(
    name: 'movie',
    createDomain: () => MovieMedia(
      id: const MovieMediaId('movie-contract'),
      title: 'Contract Movie',
      ageRating: 'PG-13',
      audienceRating: '8.1',
      characterAppearances: const [
        MovieCharacterAppearance(
          id: 'character-appearance-contract',
          characterId: 'character-contract',
          characterName: 'Lead',
          role: 'protagonist',
        ),
      ],
      contributions: const [
        MovieContributor(
          id: 'contribution-contract',
          personId: 'person-contract',
          name: 'Contract Director',
          role: 'director',
        ),
      ],
      description: 'Contract description',
      externalLinks: const [
        MovieExternalLink(
          id: 'link-contract',
          url: 'https://example.com/movie',
        ),
      ],
      identifiers: const [
        MovieIdentifier(
          id: 'identifier-contract',
          identifierType: 'tmdb',
          value: '100',
          isPrimary: true,
        ),
      ],
      originalLanguage: 'en',
      releaseDate: DateTime.utc(2020, 1, 2),
      releases: const [
        MovieRelease(
          id: MovieReleaseId('release-contract'),
          title: 'Contract Edition',
          workId: 'movie-contract',
          format: 'Blu-ray',
          media: [
            MovieReleaseMedia(
              id: MovieReleaseMediaId('media-contract'),
              releaseId: 'release-contract',
              numDiscs: 1,
            ),
          ],
        ),
      ],
      runtimeMinutes: 120,
      sortTitle: 'Contract Movie',
      subtitle: 'Contract subtitle',
      trailerUrls: const [
        MovieTrailerLink(
          id: 'trailer-contract',
          url: 'https://example.com/trailer',
        ),
      ],
    ),
    encode: (domain) => MovieWorkDto.fromJson(domain.toJson()),
    decode: MovieCoreMapper.fromWorkDto,
    equals: (left, right) =>
        left.id == right.id &&
        left.title == right.title &&
        left.ageRating == right.ageRating &&
        left.audienceRating == right.audienceRating &&
        left.characterAppearances.length == right.characterAppearances.length &&
        left.contributions.length == right.contributions.length &&
        left.description == right.description &&
        left.externalLinks.length == right.externalLinks.length &&
        left.identifiers.length == right.identifiers.length &&
        left.originalLanguage == right.originalLanguage &&
        left.releaseDate == right.releaseDate &&
        left.releases.length == right.releases.length &&
        left.runtimeMinutes == right.runtimeMinutes &&
        left.sortTitle == right.sortTitle &&
        left.subtitle == right.subtitle &&
        left.trailerUrls.length == right.trailerUrls.length,
  );

  test('MovieWorkDto fields are explicitly classified', () {
    final source = File(
      'lib/core/api/generated/collectarr_api.models.dart',
    ).readAsStringSync();
    validateCoreDtoFieldAdoption(
      source: source,
      policy: CoreFieldAdoptionPolicy(
        dtoName: 'MovieWorkDto',
        mapped: {
          'id',
          'title',
          'ageRating',
          'audienceRating',
          'characterAppearances',
          'contributions',
          'description',
          'externalLinks',
          'identifiers',
          'originalLanguage',
          'releaseDateValue',
          'releases',
          'runtimeMinutes',
          'sortTitle',
          'subtitle',
          'trailerUrls',
        },
        intentionallyIgnored: {
          'kind': 'used to validate the typed Movie DTO boundary',
        },
      ),
    );
  });
}
