import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/remote/manga_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';

abstract interface class MangaRemoteSource {
  Future<MangaMedia> fetchMedia(String id);
}

final class ApiMangaRemoteSource implements MangaRemoteSource {
  const ApiMangaRemoteSource(this._fetchWork);

  factory ApiMangaRemoteSource.fromApi(ApiClient apiClient) {
    return ApiMangaRemoteSource(apiClient.getMangaWorkDto);
  }

  final MangaWorkDtoFetcher _fetchWork;

  @override
  Future<MangaMedia> fetchMedia(String id) async {
    final dto = await _fetchWork(id);
    return MangaCoreMapper.fromWorkDto(dto);
  }
}
