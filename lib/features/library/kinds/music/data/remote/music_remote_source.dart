import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

abstract interface class MusicRemoteSource {
  Future<MusicRelease> fetchRelease(MusicReleaseId id);
}

final class ApiMusicRemoteSource implements MusicRemoteSource {
  const ApiMusicRemoteSource(this._fetchRelease);

  factory ApiMusicRemoteSource.fromApi(ApiClient apiClient) {
    return ApiMusicRemoteSource(apiClient.getMusicReleaseDto);
  }

  final MusicReleaseDtoFetcher _fetchRelease;

  @override
  Future<MusicRelease> fetchRelease(MusicReleaseId id) async {
    return MusicCoreMapper.fromReleaseDto(await _fetchRelease(id.value));
  }
}
