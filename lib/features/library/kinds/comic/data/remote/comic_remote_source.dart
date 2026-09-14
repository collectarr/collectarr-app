import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

abstract interface class ComicRemoteSource {
  Future<ComicMedia> fetchMedia(ComicMediaId id);
}

final class ApiComicRemoteSource implements ComicRemoteSource {
  const ApiComicRemoteSource(this._fetchWork);

  factory ApiComicRemoteSource.fromApi(ApiClient apiClient) {
    return ApiComicRemoteSource(apiClient.getComicWorkDto);
  }

  final ComicWorkDtoFetcher _fetchWork;

  @override
  Future<ComicMedia> fetchMedia(ComicMediaId id) async {
    final dto = await _fetchWork(id.value);
    return ComicCoreMapper.fromWorkDto(dto);
  }
}
