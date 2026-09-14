import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/game/data/remote/game_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';

abstract interface class GameRemoteSource {
  Future<GameMedia> fetchMedia(GameMediaId id);
  Future<GameRelease> fetchRelease(GameReleaseId id);
}

final class ApiGameRemoteSource implements GameRemoteSource {
  const ApiGameRemoteSource(this._fetchWork, this._fetchRelease);

  factory ApiGameRemoteSource.fromApi(ApiClient apiClient) {
    return ApiGameRemoteSource(
      apiClient.getGameWorkDto,
      apiClient.getGameReleaseDto,
    );
  }

  final GameWorkDtoFetcher _fetchWork;
  final GameReleaseDtoFetcher _fetchRelease;

  @override
  Future<GameMedia> fetchMedia(GameMediaId id) async {
    final dto = await _fetchWork(id.value);
    return GameCoreMapper.fromWorkDto(dto);
  }

  @override
  Future<GameRelease> fetchRelease(GameReleaseId id) async {
    final dto = await _fetchRelease(id.value);
    return GameCoreMapper.fromReleaseDto(dto);
  }
}
