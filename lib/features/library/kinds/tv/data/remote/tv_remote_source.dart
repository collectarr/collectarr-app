import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/remote/tv_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

abstract interface class TvRemoteSource {
  Future<TvSeries> fetchSeries(TvSeriesId id);
}

typedef TvSeriesDtoFetcher = Future<TvSeriesDto> Function(String id);

final class ApiTvRemoteSource implements TvRemoteSource {
  const ApiTvRemoteSource(this._fetchSeriesDto);

  factory ApiTvRemoteSource.fromApi(ApiClient apiClient) {
    return ApiTvRemoteSource(apiClient.getTvSeriesDto);
  }

  final TvSeriesDtoFetcher _fetchSeriesDto;

  @override
  Future<TvSeries> fetchSeries(TvSeriesId id) async {
    final dto = await _fetchSeriesDto(id.value);
    return TvCoreMapper.fromSeriesDto(dto);
  }
}
