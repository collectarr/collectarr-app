import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';

TvEpisode tvEpisodeFromDto(TvEpisodeDto dto) => TvEpisode.fromDto(dto);

TvSeason tvSeasonFromDto(TvSeasonDto dto) => TvSeason.fromDto(dto);

TvReleaseMedia tvReleaseMediaFromDto(TvReleaseMediaDto dto) =>
    TvReleaseMedia.fromDto(dto);

TvReleaseEpisodeMap tvReleaseEpisodeMapFromDto(TvReleaseEpisodeMapDto dto) =>
    TvReleaseEpisodeMap.fromDto(dto);

TvRelease tvReleaseFromDto(TvReleaseDto dto) => TvRelease.fromDto(dto);

TvSeries tvSeriesFromDto(TvSeriesDto dto) => TvSeries.fromDto(dto);
