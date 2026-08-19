import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/api/mappers/tv_mapper.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps typed tv dto data and raw release graph into domain models', () {
    final mediaJson = {
      'id': 'media-1',
      'release_id': 'release-1',
      'title': 'Disc 1',
      'format_label': 'Blu-ray',
      'disc_number': 1,
      'sequence_number': 1,
      'features': ['dub'],
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

    final series = tvSeriesFromDto(seriesDto);
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
    final release = tvReleaseFromDto(TvReleaseDto.fromJson(releaseJson));
    expect(release.media, hasLength(1));
    expect(release.media.single.episodes, hasLength(1));

    final media = tvReleaseMediaFromDto(TvReleaseMediaDto.fromJson(mediaJson));
    expect(media.discNumber, 1);
    expect(media.episodes, hasLength(1));

    final map = tvReleaseEpisodeMapFromDto(TvReleaseEpisodeMapDto.fromJson({
      'id': 'map-1',
      'release_id': 'release-1',
      'media_id': 'media-1',
      'episode_id': 'episode-1',
      'disc_number': 1,
      'sequence_number': 1,
    }));
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
    expect(tvKindModule.defaultOwnedDetails(), isA<TvOwnedDetails>());
  });
}
