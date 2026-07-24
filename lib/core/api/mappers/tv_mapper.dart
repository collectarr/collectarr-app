import 'package:collectarr_app/features/library/kinds/tv/tv_domain.dart';
import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_release.dart';

TvEpisode tvEpisodeFromDto(dynamic dto) => const TvEpisode();

TvSeason tvSeasonFromDto(dynamic dto) => const TvSeason();

TvReleaseMedia tvReleaseMediaFromDto(dynamic dto) => const TvReleaseMedia();

TvReleaseEpisodeMap tvReleaseEpisodeMapFromDto(dynamic dto) => const TvReleaseEpisodeMap();

VideoRelease tvReleaseFromDto(dynamic dto) => const VideoRelease(id: '', title: '');

TvSeries tvSeriesFromDto(dynamic dto) => const TvSeries();
