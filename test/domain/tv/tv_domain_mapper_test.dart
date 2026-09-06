import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TvCoreMapper maps generated Core DTOs into TV-owned models', () {
    final dto = TvSeriesDto.fromJson({
      'id': 'series-typed',
      'title': 'The Expanse',
      'description': 'A political space opera.',
      'original_air_date': '2015-12-14T00:00:00Z',
      'end_date': '2022-01-14T00:00:00Z',
      'season_count': 6,
      'episode_count': 62,
      'network': 'Syfy',
      'original_language': 'en',
      'status': 'Ended',
      'seasons': [
        {
          'id': 'season-typed',
          'series_id': 'series-typed',
          'season_number': 1,
          'episode_count': 10,
          'episodes': [
            {
              'id': 'episode-typed',
              'series_id': 'series-typed',
              'season_id': 'season-typed',
              'season_number': 1,
              'episode_number': 1,
              'episode_title': 'Dulcinea',
              'runtime_minutes': 43,
            },
          ],
        },
      ],
      'releases': [
        {
          'id': 'release-typed',
          'series_id': 'series-typed',
          'title': 'Season One Blu-ray',
          'format': 'Blu-ray',
          'media': [
            {
              'id': 'media-typed',
              'release_id': 'release-typed',
              'media_number': 1,
              'media_type': 'disc',
              'episode_count': 5,
            },
          ],
          'episode_mappings': [
            {
              'id': 'map-typed',
              'release_id': 'release-typed',
              'media_id': 'media-typed',
              'episode_id': 'episode-typed',
              'disc_number': 1,
              'sequence_number': 1,
            },
          ],
        },
      ],
      'contributions': [
        {'name': 'Mark Fergus', 'role': 'Creator'},
      ],
      'identifiers': [
        {
          'id': 'id-typed',
          'identifier_type': 'imdb',
          'value': 'tt3230854',
          'is_primary': true,
        },
      ],
      'character_appearances': [
        {
          'id': 'character-typed',
          'character_id': 'holden',
          'character_name': 'James Holden',
          'role': 'Lead',
        },
      ],
      'kind': 'tv',
    });

    final series = TvCoreMapper.fromSeriesDto(dto);

    expect(series.id, 'series-typed');
    expect(series.originalAirDate, DateTime.utc(2015, 12, 14));
    expect(series.seasons.single.episodes.single.episodeNumber, 1);
    expect(series.releases.single.format, 'Blu-ray');
    expect(series.releases.single.media.single.mediaNumber, 1);
    expect(series.releases.single.episodeMappings.single.discNumber, 1);
    expect(series.contributions.single.name, 'Mark Fergus');
    expect(series.identifiers.single.value, 'tt3230854');
    expect(series.characterAppearances.single.characterName, 'James Holden');
  });

  test('maps typed tv dto data and raw release graph into domain models', () {
    final mediaJson = {
      'id': 'media-1',
      'release_id': 'release-1',
      'title': 'Disc 1',
      'format': 'Blu-ray',
      'media_number': 1,
      'media_type': 'disc',
      'episodes': [
        {
          'id': 'episode-1',
          'series_id': 'series-1',
          'season_id': 'season-1',
          'season_number': 1,
          'episode_number': 1,
          'title': 'Asteroid Blues',
          'runtime_minutes': 24,
        },
      ],
    };
    final seriesDto = TvSeriesDto.fromJson({
      'id': 'series-1',
      'title': 'Cowboy Bebop',
      'description': 'A space western.',
      'original_air_date': '1998-04-03T00:00:00Z',
      'season_count': 1,
      'episode_count': 2,
      'network': 'Sunrise',
      'original_language': 'ja',
      'media': const <dynamic>[],
      'seasons': const <dynamic>[],
      'releases': [
        {
          'id': 'release-1',
          'series_id': 'series-1',
          'title': 'Blu-ray',
          'release_date': '2024-01-05T00:00:00Z',
          'country': 'JP',
          'language': 'ja',
          'media': [mediaJson],
          'episode_mappings': [
            {
              'id': 'map-1',
              'release_id': 'release-1',
              'media_id': 'media-1',
              'episode_id': 'episode-1',
              'disc_number': 1,
              'sequence_number': 1,
            },
          ],
        },
      ],
      'contributions': [
        {'name': 'Shinichiro Watanabe', 'role': 'Director'},
      ],
      'character_appearances': const <dynamic>[],
      'identifiers': const <dynamic>[],
      'kind': 'tv',
    });

    final series = TvCoreMapper.fromSeriesDto(seriesDto);
    expect(series.id, 'series-1');
    expect(series.title, 'Cowboy Bebop');
    expect(series.seasons, isEmpty);
    expect(series.releases, hasLength(1));
    expect(series.releases.single.media, hasLength(1));
    expect(series.releases.single.episodeMappings, hasLength(1));

    final season = TvSeason.fromJson({
      'id': 'season-1',
      'series_id': 'series-1',
      'season_number': 1,
      'title': 'Season 1',
      'release_date': '1998-04-03T00:00:00Z',
      'episode_count': 2,
      'episodes': [
        {
          'id': 'episode-1',
          'series_id': 'series-1',
          'season_id': 'season-1',
          'season_number': 1,
          'episode_number': 1,
          'title': 'Asteroid Blues',
          'runtime_minutes': 24,
        },
      ],
    });
    expect(season.episodes, hasLength(1));
    expect(season.episodes.single.title, 'Asteroid Blues');

    final Map<String, dynamic> raw = seriesDto.raw;
    final releaseJson =
        (raw['releases'] as List<dynamic>).cast<Map<String, dynamic>>()[0];
    final release =
        TvCoreMapper.fromReleaseDto(TvReleaseDto.fromJson(releaseJson));
    expect(release.media, hasLength(1));
    expect(release.media.single.episodes, hasLength(1));

    final media = TvCoreMapper.fromReleaseMediaDto(
      TvReleaseMediaDto.fromJson(mediaJson),
    );
    expect(media.mediaNumber, 1);
    expect(media.episodes, hasLength(1));

    final map = TvCoreMapper.fromReleaseEpisodeMapDto(
      TvReleaseEpisodeMapDto.fromJson({
        'id': 'map-1',
        'release_id': 'release-1',
        'media_id': 'media-1',
        'episode_id': 'episode-1',
        'disc_number': 1,
        'sequence_number': 1,
      }),
    );
    expect(map.releaseId, 'release-1');
    expect(map.mediaId, 'media-1');
    expect(map.episodeId, 'episode-1');
  });

  test('TvSeriesMetadata and season/episode hierarchy serialization roundtrips',
      () {
    final meta = TvSeriesMetadata(
      title: 'Breaking Bad',
      originalTitle: 'Breaking Bad',
      synopsis: 'A chemistry teacher turns to cooking meth.',
      firstAirDate: DateTime.utc(2008, 1, 20),
      lastAirDate: DateTime.utc(2013, 9, 29),
      status: 'Ended',
      network: 'AMC',
      streamingService: 'Netflix',
      productionCompanies: const ['Sony Pictures Television', 'High Bridge'],
      country: 'US',
      originalLanguage: 'en',
      genres: const ['Crime', 'Drama', 'Thriller'],
      contentRating: 'TV-MA',
      seasonCount: 5,
      episodeCount: 62,
      episodeRuntimeMinutes: 47,
      cast: const [
        TvPersonCredit(
            name: 'Bryan Cranston', character: 'Walter White', role: 'Actor'),
        TvPersonCredit(
            name: 'Aaron Paul', character: 'Jesse Pinkman', role: 'Actor'),
      ],
      crew: const [
        TvPersonCredit(name: 'Vince Gilligan', role: 'Creator'),
      ],
      seasons: [
        TvSeasonMetadata(
          seasonNumber: 1,
          title: 'Season 1',
          airDate: DateTime.utc(2008, 1, 20),
          episodeCount: 7,
          episodes: [
            TvEpisodeMetadata(
              number: 1,
              title: 'Pilot',
              synopsis: 'Walter discovers he has lung cancer.',
              airDate: DateTime.utc(2008, 1, 20),
              runtimeMinutes: 58,
            ),
          ],
        ),
      ],
      releases: const [
        TvPhysicalReleaseMetadata(
          id: 'rel-bb-complete',
          title: 'The Complete Series Barrel Edition',
          seasonOrSeriesBoxSet: 'Complete Series',
          region: 'Region Free',
          discCount: 16,
          packaging: 'Collector Barrel',
          hdrFormats: ['HDR10'],
          audioTracks: ['DTS-HD Master Audio 5.1'],
          subtitles: ['English', 'Spanish'],
        ),
      ],
    );

    final json = meta.toJson();
    final fromJson = TvSeriesMetadata.fromJson(json);

    expect(fromJson.title, 'Breaking Bad');
    expect(fromJson.network, 'AMC');
    expect(fromJson.seasons, hasLength(1));
    expect(fromJson.seasons.single.episodes.single.title, 'Pilot');
    expect(fromJson.releases, hasLength(1));
    expect(fromJson.releases.single.packaging, 'Collector Barrel');
  });

  test('TvKindModule uses TV-owned capabilities', () {
    expect(tvKindModule.kind, CatalogMediaKind.tv);
    expect(tvKindModule.add.kind, CatalogMediaKind.tv);
    expect(tvKindModule.add.createInitialDraft(), isA<TvAddDraft>());
    expect(tvKindModule.ownedDetailsCodec, isA<TvOwnedDetailsCodec>());
    expect(
        tvKindModule.ownedDetailsCodec.defaultDetails(), isA<TvOwnedDetails>());
  });
}
