import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

final class AnimePreferenceCodec
    implements LibraryWorkspacePreferenceCodec<AnimeKind> {
  const AnimePreferenceCodec();

  static const Map<String, LibraryFieldId<AnimeKind, Object?>> _columnMap = {
    'status': AnimeFieldIds.status,
    'anime.status': AnimeFieldIds.status,
    'cover': AnimeFieldIds.cover,
    'anime.cover': AnimeFieldIds.cover,
    'title': AnimeFieldIds.title,
    'anime.title': AnimeFieldIds.title,
    'studio': AnimeFieldIds.studio,
    'anime.studio': AnimeFieldIds.studio,
    'publisher': AnimeFieldIds.publisher,
    'anime.publisher': AnimeFieldIds.publisher,
    'release_date': AnimeFieldIds.releaseDate,
    'anime.release_date': AnimeFieldIds.releaseDate,
    'release_year': AnimeFieldIds.releaseYear,
    'anime.release_year': AnimeFieldIds.releaseYear,
    'episode_count': AnimeFieldIds.episodeCount,
    'anime.episode_count': AnimeFieldIds.episodeCount,
    'format': AnimeFieldIds.format,
    'anime.format': AnimeFieldIds.format,
    'barcode': AnimeFieldIds.barcode,
    'anime.barcode': AnimeFieldIds.barcode,
    'rating': AnimeFieldIds.rating,
    'anime.rating': AnimeFieldIds.rating,
    'condition': AnimeFieldIds.condition,
    'anime.condition': AnimeFieldIds.condition,
    'price': AnimeFieldIds.pricePaid,
    'price_paid': AnimeFieldIds.pricePaid,
    'anime.price': AnimeFieldIds.pricePaid,
    'anime.price_paid': AnimeFieldIds.pricePaid,
    'location': AnimeFieldIds.location,
    'anime.location': AnimeFieldIds.location,
    'wishlist': AnimeFieldIds.wishlist,
    'anime.wishlist': AnimeFieldIds.wishlist,
    'updated': AnimeFieldIds.updatedAt,
    'updated_at': AnimeFieldIds.updatedAt,
    'anime.updated': AnimeFieldIds.updatedAt,
    'anime.updated_at': AnimeFieldIds.updatedAt,
    'added': AnimeFieldIds.addedAt,
    'added_at': AnimeFieldIds.addedAt,
    'anime.added': AnimeFieldIds.addedAt,
    'anime.added_at': AnimeFieldIds.addedAt,
    'watch_status': AnimeFieldIds.watchStatus,
    'anime.watch_status': AnimeFieldIds.watchStatus,
  };

  static const Map<String, LibrarySortId<AnimeKind>> _sortMap = {
    'title': AnimeSortIds.title,
    'anime.title': AnimeSortIds.title,
    'studio': AnimeSortIds.studio,
    'anime.studio': AnimeSortIds.studio,
    'publisher': AnimeSortIds.publisher,
    'anime.publisher': AnimeSortIds.publisher,
    'release_date': AnimeSortIds.releaseDate,
    'anime.release_date': AnimeSortIds.releaseDate,
    'release_year': AnimeSortIds.releaseYear,
    'anime.release_year': AnimeSortIds.releaseYear,
    'rating': AnimeSortIds.rating,
    'anime.rating': AnimeSortIds.rating,
    'price': AnimeSortIds.pricePaid,
    'price_paid': AnimeSortIds.pricePaid,
    'anime.price': AnimeSortIds.pricePaid,
    'anime.price_paid': AnimeSortIds.pricePaid,
    'updated': AnimeSortIds.updatedAt,
    'updated_at': AnimeSortIds.updatedAt,
    'anime.updated': AnimeSortIds.updatedAt,
    'anime.updated_at': AnimeSortIds.updatedAt,
  };

  static const Map<String, LibraryGroupId<AnimeKind, Object?>> _groupMap = {
    'studio': AnimeGroupIds.studio,
    'anime.studio': AnimeGroupIds.studio,
    'publisher': AnimeGroupIds.publisher,
    'anime.publisher': AnimeGroupIds.publisher,
    'format': AnimeGroupIds.format,
    'anime.format': AnimeGroupIds.format,
    'release_year': AnimeGroupIds.releaseYear,
    'anime.release_year': AnimeGroupIds.releaseYear,
    'location': AnimeGroupIds.location,
    'anime.location': AnimeGroupIds.location,
    'condition': AnimeGroupIds.condition,
    'anime.condition': AnimeGroupIds.condition,
    'rating': AnimeGroupIds.rating,
    'anime.rating': AnimeGroupIds.rating,
    'watch_status': AnimeGroupIds.watchStatus,
    'anime.watch_status': AnimeGroupIds.watchStatus,
  };

  @override
  LibraryFieldId<AnimeKind, Object?>? decodeColumn(String persisted) =>
      _columnMap[persisted];

  @override
  LibrarySortId<AnimeKind>? decodeSort(String persisted) => _sortMap[persisted];

  @override
  LibraryGroupId<AnimeKind, Object?>? decodeGroup(String persisted) =>
      _groupMap[persisted];

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<AnimeKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
