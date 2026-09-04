import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/kinds/book/data/remote/book_core_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';

abstract interface class BookRemoteSource {
  Future<BookMedia> fetchMedia(BookMediaId id);
}

final class ApiBookRemoteSource implements BookRemoteSource {
  const ApiBookRemoteSource(this._fetchWork);

  factory ApiBookRemoteSource.fromApi(ApiClient apiClient) {
    return ApiBookRemoteSource(apiClient.getBookWorkDto);
  }

  final BookWorkDtoFetcher _fetchWork;

  @override
  Future<BookMedia> fetchMedia(BookMediaId id) async {
    final dto = await _fetchWork(id.value);
    return BookCoreMapper.fromWorkDto(dto);
  }
}
