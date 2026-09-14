import 'dart:io';

import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_episode.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/core_field_adoption_contract.dart';
import '../../contracts/core_mapping_contract.dart';

void main() {
  test('AnimeSeriesDto maps directly into Anime-owned typed models', () {
    final dto = AnimeSeriesDto.fromJson({
      'id': 'anime-1',
      'kind': 'anime',
      'title': 'Cowboy Bebop',
      'anime_type': 'TV',
      'sort_title': 'Cowboy Bebop',
      'description': 'A bounty hunting crew travels through space.',
      'original_air_date': '1998-04-03',
      'end_date': '1999-04-24',
      'original_language': 'ja',
      'status': 'finished',
      'episode_count': 26,
      'cover_image_url': 'https://example.com/cowboy-bebop.jpg',
      'character_appearances': [
        {
          'id': 'appearance-1',
          'character_id': 'character-1',
          'character_name': 'Spike Spiegel',
          'role': 'main',
        },
      ],
      'contributions': [
        {
          'id': 'contribution-1',
          'person_id': 'person-1',
          'name': 'Shinichiro Watanabe',
          'role': 'director',
          'image_url': 'https://example.com/watanabe.jpg',
          'sequence': 1,
        },
      ],
      'identifiers': [
        {
          'id': 'identifier-1',
          'identifier_type': 'mal',
          'value': '1',
          'is_primary': true,
        },
      ],
      'episodes': [
        {
          'id': 'episode-1',
          'series_id': 'anime-1',
          'episode_number': 1,
          'episode_title': 'Asteroid Blues',
          'description': 'The crew takes a bounty near Mars.',
          'air_date': '1998-04-03',
          'runtime_minutes': 24,
          'cover_image_key': 'episode-key-1',
        },
      ],
      'releases': [
        {
          'id': 'release-1',
          'kind': 'anime',
          'series_id': 'anime-1',
          'release_title': 'Complete Collection',
          'format': 'Blu-ray',
          'region_code': 'B',
          'barcode': '123456789',
          'media_count': 4,
        },
      ],
    });

    final media = AnimeCoreMapper.fromSeriesDto(dto);

    expect(media.id, const AnimeMediaId('anime-1'));
    expect(media.title, 'Cowboy Bebop');
    expect(media.animeType, 'TV');
    expect(media.description, contains('bounty hunting'));
    expect(media.originalAirDate, DateTime(1998, 4, 3));
    expect(media.endDate, DateTime(1999, 4, 24));
    expect(media.coverImageUrl, 'https://example.com/cowboy-bebop.jpg');
    expect(media.characterAppearances.single.characterName, 'Spike Spiegel');
    expect(media.contributions.single.personId, 'person-1');
    expect(media.identifiers.single.value, '1');
    expect(media.episodes.single.id, const AnimeEpisodeId('episode-1'));
    expect(media.episodes.single.seriesId, const AnimeMediaId('anime-1'));
    expect(media.episodes.single.title, 'Asteroid Blues');
    expect(media.episodes.single.episodeNumber, 1);
    expect(media.releases.single.typedId, const AnimeReleaseId('release-1'));
    expect(media.releases.single.seriesId, const AnimeMediaId('anime-1'));
    expect(media.releases.single.format, 'Blu-ray');
    expect(media.releases.single.barcode, '123456789');
  });

  test('Anime episode and release payloads map independently', () {
    final episode = AnimeCoreMapper.fromEpisodePayload({
      'id': 'episode-2',
      'kind': 'anime',
      'series_id': 'anime-2',
      'episode_number': 12.5,
      'episode_title': 'Finale',
    });
    final release = AnimeCoreMapper.fromReleasePayload({
      'id': 'release-2',
      'kind': 'anime',
      'series_id': 'anime-2',
      'release_title': 'Collector Edition',
      'publisher': 'Anime Works',
      'language': 'ja',
    });

    expect(episode.typedId, const AnimeEpisodeId('episode-2'));
    expect(episode.seriesId, const AnimeMediaId('anime-2'));
    expect(episode.episodeNumber, 12.5);
    expect(release.typedId, const AnimeReleaseId('release-2'));
    expect(release.seriesId, const AnimeMediaId('anime-2'));
    expect(release.publisher, 'Anime Works');
  });

  test('Anime mapper rejects a DTO or payload with the wrong kind', () {
    final dto = AnimeSeriesDto.fromJson({
      'id': 'not-anime',
      'kind': 'book',
      'title': 'Wrong kind',
    });

    expect(
      () => AnimeCoreMapper.fromSeriesDto(dto),
      throwsA(isA<StateError>()),
    );
    expect(
      () => AnimeCoreMapper.fromEpisodePayload({
        'id': 'episode-wrong',
        'kind': 'tv',
        'series_id': 'anime-1',
      }),
      throwsA(isA<StateError>()),
    );
  });

  test('Anime remote source maps a series fetch', () async {
    final source = ApiAnimeRemoteSource(
      (id) async => AnimeSeriesDto.fromJson({
        'id': id,
        'kind': 'anime',
        'title': 'Samurai Champloo',
      }),
    );

    final media = await source.fetchMedia(const AnimeMediaId('anime-3'));

    expect(media.id, const AnimeMediaId('anime-3'));
    expect(media.title, 'Samurai Champloo');
  });

  test('AnimeTracking round-trips typed references and progress', () {
    final tracking = AnimeTracking(
      id: 'tracking-1',
      mediaId: const AnimeMediaId('anime-1'),
      episodeId: const AnimeEpisodeId('episode-1'),
      status: 'watching',
      rating: 9,
      progressCurrent: 12,
      progressTotal: 26,
      timesCompleted: 1,
      seasonNumber: 1,
      episodeNumber: 12.5,
      episodeRatings: const {'episode-1': 9},
      updatedAt: DateTime.utc(2026, 9, 5),
    );

    final restored = AnimeTracking.fromJson(tracking.toJson());

    expect(restored.id, 'tracking-1');
    expect(restored.mediaId, const AnimeMediaId('anime-1'));
    expect(restored.episodeId, const AnimeEpisodeId('episode-1'));
    expect(restored.status, 'watching');
    expect(restored.progressCurrent, 12);
    expect(restored.episodeNumber, 12.5);
    expect(restored.episodeRatings, const {'episode-1': 9});
  });

  defineCoreMappingContract<AnimeMedia, AnimeSeriesDto>(
    name: 'anime',
    createDomain: () => AnimeMedia(
      id: const AnimeMediaId('anime-contract'),
      title: 'Contract Anime',
      animeType: 'TV',
      description: 'Contract description',
      endDate: DateTime.utc(2020, 1, 2),
      episodeCount: 12,
      episodes: const [
        AnimeEpisode(
          id: AnimeEpisodeId('episode-contract'),
          seriesId: AnimeMediaId('anime-contract'),
          episodeNumber: 1,
          title: 'Contract episode',
        ),
      ],
      originalAirDate: DateTime.utc(2019, 10, 1),
      originalLanguage: 'ja',
      sortTitle: 'Contract Anime',
      status: 'finished',
      releases: const [
        AnimeRelease(
          id: AnimeReleaseId('release-contract'),
          title: 'Contract release',
          seriesId: AnimeMediaId('anime-contract'),
          format: 'Blu-ray',
        ),
      ],
      rawPayload: const {
        'anime_type': 'TV',
        'cover_image_url': 'https://example.com/contract.jpg',
      },
    ),
    encode: (domain) => AnimeSeriesDto.fromJson(domain.toJson()),
    decode: AnimeCoreMapper.fromSeriesDto,
    equals: (left, right) =>
        left.id == right.id &&
        left.title == right.title &&
        left.animeType == right.animeType &&
        left.description == right.description &&
        left.endDate == right.endDate &&
        left.episodeCount == right.episodeCount &&
        left.episodes.length == right.episodes.length &&
        left.originalAirDate == right.originalAirDate &&
        left.originalLanguage == right.originalLanguage &&
        left.sortTitle == right.sortTitle &&
        left.status == right.status &&
        left.releases.length == right.releases.length,
  );

  test('AnimeSeriesDto fields are explicitly classified', () {
    final source = File(
      'lib/core/api/generated/collectarr_api.models.dart',
    ).readAsStringSync();
    validateCoreDtoFieldAdoption(
      source: source,
      policy: CoreFieldAdoptionPolicy(
        dtoName: 'AnimeSeriesDto',
        mapped: {
          'id',
          'title',
          'characterAppearances',
          'contributions',
          'description',
          'endDate',
          'episodeCount',
          'episodes',
          'identifiers',
          'originalAirDate',
          'originalLanguage',
          'sortTitle',
          'status',
        },
        intentionallyIgnored: {
          'kind': 'used to validate the typed Anime DTO boundary',
        },
      ),
    );
  });
}
