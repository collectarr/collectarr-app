import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

final class TvPreferenceCodec
    implements LibraryWorkspacePreferenceCodec<TvKind> {
  const TvPreferenceCodec();

  static const Map<String, LibraryFieldId<TvKind, Object?>> _columnMap = {
    'status': TvFieldIds.status,
    'tv.status': TvFieldIds.status,
    'cover': TvFieldIds.cover,
    'tv.cover': TvFieldIds.cover,
    'title': TvFieldIds.title,
    'tv.title': TvFieldIds.title,
    'series': TvFieldIds.series,
    'tv.series': TvFieldIds.series,
    'network': TvFieldIds.network,
    'tv.network': TvFieldIds.network,
    'creator': TvFieldIds.creator,
    'tv.creator': TvFieldIds.creator,
    'release_date': TvFieldIds.releaseDate,
    'tv.release_date': TvFieldIds.releaseDate,
    'release_year': TvFieldIds.releaseYear,
    'tv.release_year': TvFieldIds.releaseYear,
    'season_count': TvFieldIds.seasonCount,
    'tv.season_count': TvFieldIds.seasonCount,
    'episode_count': TvFieldIds.episodeCount,
    'tv.episode_count': TvFieldIds.episodeCount,
    'barcode': TvFieldIds.barcode,
    'tv.barcode': TvFieldIds.barcode,
    'rating': TvFieldIds.rating,
    'tv.rating': TvFieldIds.rating,
    'condition': TvFieldIds.condition,
    'tv.condition': TvFieldIds.condition,
    'price': TvFieldIds.pricePaid,
    'price_paid': TvFieldIds.pricePaid,
    'tv.price': TvFieldIds.pricePaid,
    'tv.price_paid': TvFieldIds.pricePaid,
    'location': TvFieldIds.location,
    'tv.location': TvFieldIds.location,
    'wishlist': TvFieldIds.wishlist,
    'tv.wishlist': TvFieldIds.wishlist,
    'updated': TvFieldIds.updatedAt,
    'updated_at': TvFieldIds.updatedAt,
    'tv.updated': TvFieldIds.updatedAt,
    'tv.updated_at': TvFieldIds.updatedAt,
    'added': TvFieldIds.addedAt,
    'added_at': TvFieldIds.addedAt,
    'tv.added': TvFieldIds.addedAt,
    'tv.added_at': TvFieldIds.addedAt,
    'watch_status': TvFieldIds.watchStatus,
    'tv.watch_status': TvFieldIds.watchStatus,
  };

  static const Map<String, LibrarySortId<TvKind>> _sortMap = {
    'title': TvSortIds.title,
    'tv.title': TvSortIds.title,
    'series': TvSortIds.series,
    'tv.series': TvSortIds.series,
    'network': TvSortIds.network,
    'tv.network': TvSortIds.network,
    'release_date': TvSortIds.releaseDate,
    'tv.release_date': TvSortIds.releaseDate,
    'release_year': TvSortIds.releaseYear,
    'tv.release_year': TvSortIds.releaseYear,
    'rating': TvSortIds.rating,
    'tv.rating': TvSortIds.rating,
    'price': TvSortIds.pricePaid,
    'price_paid': TvSortIds.pricePaid,
    'tv.price': TvSortIds.pricePaid,
    'tv.price_paid': TvSortIds.pricePaid,
    'updated': TvSortIds.updatedAt,
    'updated_at': TvSortIds.updatedAt,
    'tv.updated': TvSortIds.updatedAt,
    'tv.updated_at': TvSortIds.updatedAt,
  };

  static const Map<String, LibraryGroupId<TvKind, Object?>> _groupMap = {
    'series': TvGroupIds.series,
    'tv.series': TvGroupIds.series,
    'network': TvGroupIds.network,
    'tv.network': TvGroupIds.network,
    'creator': TvGroupIds.creator,
    'tv.creator': TvGroupIds.creator,
    'release_year': TvGroupIds.releaseYear,
    'tv.release_year': TvGroupIds.releaseYear,
    'location': TvGroupIds.location,
    'tv.location': TvGroupIds.location,
    'condition': TvGroupIds.condition,
    'tv.condition': TvGroupIds.condition,
    'rating': TvGroupIds.rating,
    'tv.rating': TvGroupIds.rating,
    'watch_status': TvGroupIds.watchStatus,
    'tv.watch_status': TvGroupIds.watchStatus,
  };

  @override
  LibraryFieldId<TvKind, Object?>? decodeColumn(String persisted) =>
      _columnMap[persisted];

  @override
  LibrarySortId<TvKind>? decodeSort(String persisted) => _sortMap[persisted];

  @override
  LibraryGroupId<TvKind, Object?>? decodeGroup(String persisted) =>
      _groupMap[persisted];

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<TvKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
