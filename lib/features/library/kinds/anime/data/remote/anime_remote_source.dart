import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/anime/data/remote/anime_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';

abstract interface class AnimeRemoteSource {
  Future<AnimeMedia> fetchMedia(AnimeMediaId id);
}

final class ApiAnimeRemoteSource implements AnimeRemoteSource {
  const ApiAnimeRemoteSource(this._fetchSeries);

  factory ApiAnimeRemoteSource.fromApi(ApiClient apiClient) {
    return ApiAnimeRemoteSource(apiClient.getAnimeSeriesDto);
  }

  final AnimeSeriesDtoFetcher _fetchSeries;

  @override
  Future<AnimeMedia> fetchMedia(AnimeMediaId id) async {
    final dto = await _fetchSeries(id.value);
    return AnimeCoreMapper.fromSeriesDto(dto);
  }
}
