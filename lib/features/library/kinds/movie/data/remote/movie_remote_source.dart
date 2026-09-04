import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/remote/movie_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';

abstract interface class MovieRemoteSource {
  Future<MovieMedia> fetchMedia(MovieMediaId id);
}

final class ApiMovieRemoteSource implements MovieRemoteSource {
  const ApiMovieRemoteSource(this._fetchWork);

  factory ApiMovieRemoteSource.fromApi(ApiClient apiClient) {
    return ApiMovieRemoteSource(apiClient.getMovieWorkDto);
  }

  final MovieWorkDtoFetcher _fetchWork;

  @override
  Future<MovieMedia> fetchMedia(MovieMediaId id) async {
    final dto = await _fetchWork(id.value);
    return MovieCoreMapper.fromWorkDto(dto);
  }
}
