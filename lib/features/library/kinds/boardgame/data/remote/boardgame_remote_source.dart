import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/remote/boardgame_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';

abstract interface class BoardGameRemoteSource {
  Future<BoardGameMedia> fetchMedia(BoardGameMediaId id);
  Future<BoardGameEdition> fetchEdition(BoardGameEditionId id);
}

final class ApiBoardGameRemoteSource implements BoardGameRemoteSource {
  const ApiBoardGameRemoteSource(this._fetchWork, this._fetchEdition);

  factory ApiBoardGameRemoteSource.fromApi(ApiClient apiClient) {
    return ApiBoardGameRemoteSource(
      apiClient.getBoardGameWorkDto,
      apiClient.getBoardGameEditionDto,
    );
  }

  final BoardGameWorkDtoFetcher _fetchWork;
  final BoardGameEditionDtoFetcher _fetchEdition;

  @override
  Future<BoardGameMedia> fetchMedia(BoardGameMediaId id) async {
    final dto = await _fetchWork(id.value);
    return BoardGameCoreMapper.fromWorkDto(dto);
  }

  @override
  Future<BoardGameEdition> fetchEdition(BoardGameEditionId id) async {
    final dto = await _fetchEdition(id.value);
    return BoardGameCoreMapper.fromEditionDto(dto);
  }
}
