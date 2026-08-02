import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

final class MoviePreferenceCodec
    implements LibraryWorkspacePreferenceCodec<MovieKind> {
  const MoviePreferenceCodec();

  static const Map<String, LibraryFieldId<MovieKind, Object?>> _columnMap = {
    'status': MovieFieldIds.status,
    'movie.status': MovieFieldIds.status,
    'cover': MovieFieldIds.cover,
    'movie.cover': MovieFieldIds.cover,
    'title': MovieFieldIds.title,
    'movie.title': MovieFieldIds.title,
    'director': MovieFieldIds.director,
    'movie.director': MovieFieldIds.director,
    'publisher': MovieFieldIds.publisher,
    'movie.publisher': MovieFieldIds.publisher,
    'release_date': MovieFieldIds.releaseDate,
    'movie.release_date': MovieFieldIds.releaseDate,
    'release_year': MovieFieldIds.releaseYear,
    'movie.release_year': MovieFieldIds.releaseYear,
    'runtime_minutes': MovieFieldIds.runtimeMinutes,
    'movie.runtime_minutes': MovieFieldIds.runtimeMinutes,
    'format': MovieFieldIds.format,
    'movie.format': MovieFieldIds.format,
    'barcode': MovieFieldIds.barcode,
    'movie.barcode': MovieFieldIds.barcode,
    'rating': MovieFieldIds.rating,
    'movie.rating': MovieFieldIds.rating,
    'condition': MovieFieldIds.condition,
    'movie.condition': MovieFieldIds.condition,
    'price': MovieFieldIds.pricePaid,
    'price_paid': MovieFieldIds.pricePaid,
    'movie.price': MovieFieldIds.pricePaid,
    'movie.price_paid': MovieFieldIds.pricePaid,
    'location': MovieFieldIds.location,
    'movie.location': MovieFieldIds.location,
    'wishlist': MovieFieldIds.wishlist,
    'movie.wishlist': MovieFieldIds.wishlist,
    'updated': MovieFieldIds.updatedAt,
    'updated_at': MovieFieldIds.updatedAt,
    'movie.updated': MovieFieldIds.updatedAt,
    'movie.updated_at': MovieFieldIds.updatedAt,
    'added': MovieFieldIds.addedAt,
    'added_at': MovieFieldIds.addedAt,
    'movie.added': MovieFieldIds.addedAt,
    'movie.added_at': MovieFieldIds.addedAt,
    'watch_status': MovieFieldIds.watchStatus,
    'movie.watch_status': MovieFieldIds.watchStatus,
    'edition_label': MovieFieldIds.editionLabel,
    'movie.edition_label': MovieFieldIds.editionLabel,
  };

  static const Map<String, LibrarySortId<MovieKind>> _sortMap = {
    'title': MovieSortIds.title,
    'movie.title': MovieSortIds.title,
    'director': MovieSortIds.director,
    'movie.director': MovieSortIds.director,
    'publisher': MovieSortIds.publisher,
    'movie.publisher': MovieSortIds.publisher,
    'release_date': MovieSortIds.releaseDate,
    'movie.release_date': MovieSortIds.releaseDate,
    'release_year': MovieSortIds.releaseYear,
    'movie.release_year': MovieSortIds.releaseYear,
    'runtime_minutes': MovieSortIds.runtimeMinutes,
    'movie.runtime_minutes': MovieSortIds.runtimeMinutes,
    'rating': MovieSortIds.rating,
    'movie.rating': MovieSortIds.rating,
    'price': MovieSortIds.pricePaid,
    'price_paid': MovieSortIds.pricePaid,
    'movie.price': MovieSortIds.pricePaid,
    'movie.price_paid': MovieSortIds.pricePaid,
    'updated': MovieSortIds.updatedAt,
    'updated_at': MovieSortIds.updatedAt,
    'movie.updated': MovieSortIds.updatedAt,
    'movie.updated_at': MovieSortIds.updatedAt,
  };

  static const Map<String, LibraryGroupId<MovieKind, Object?>> _groupMap = {
    'director': MovieGroupIds.director,
    'movie.director': MovieGroupIds.director,
    'publisher': MovieGroupIds.publisher,
    'movie.publisher': MovieGroupIds.publisher,
    'format': MovieGroupIds.format,
    'movie.format': MovieGroupIds.format,
    'release_year': MovieGroupIds.releaseYear,
    'movie.release_year': MovieGroupIds.releaseYear,
    'location': MovieGroupIds.location,
    'movie.location': MovieGroupIds.location,
    'condition': MovieGroupIds.condition,
    'movie.condition': MovieGroupIds.condition,
    'rating': MovieGroupIds.rating,
    'movie.rating': MovieGroupIds.rating,
    'watch_status': MovieGroupIds.watchStatus,
    'movie.watch_status': MovieGroupIds.watchStatus,
  };

  @override
  LibraryFieldId<MovieKind, Object?>? decodeColumn(String persisted) =>
      _columnMap[persisted];

  @override
  LibrarySortId<MovieKind>? decodeSort(String persisted) => _sortMap[persisted];

  @override
  LibraryGroupId<MovieKind, Object?>? decodeGroup(String persisted) =>
      _groupMap[persisted];

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<MovieKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
