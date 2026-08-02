import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

final class MangaPreferenceCodec
    implements LibraryWorkspacePreferenceCodec<MangaKind> {
  const MangaPreferenceCodec();

  static const Map<String, LibraryFieldId<MangaKind, Object?>> _columnMap = {
    'status': MangaFieldIds.status,
    'manga.status': MangaFieldIds.status,
    'cover': MangaFieldIds.cover,
    'manga.cover': MangaFieldIds.cover,
    'series': MangaFieldIds.series,
    'manga.series': MangaFieldIds.series,
    'title': MangaFieldIds.title,
    'manga.title': MangaFieldIds.title,
    'number': MangaFieldIds.volumeNumber,
    'volume_number': MangaFieldIds.volumeNumber,
    'manga.number': MangaFieldIds.volumeNumber,
    'manga.volume_number': MangaFieldIds.volumeNumber,
    'publisher': MangaFieldIds.publisher,
    'manga.publisher': MangaFieldIds.publisher,
    'release_date': MangaFieldIds.releaseDate,
    'manga.release_date': MangaFieldIds.releaseDate,
    'barcode': MangaFieldIds.barcode,
    'manga.barcode': MangaFieldIds.barcode,
    'rating': MangaFieldIds.rating,
    'manga.rating': MangaFieldIds.rating,
    'condition': MangaFieldIds.condition,
    'manga.condition': MangaFieldIds.condition,
    'price': MangaFieldIds.pricePaid,
    'price_paid': MangaFieldIds.pricePaid,
    'manga.price': MangaFieldIds.pricePaid,
    'manga.price_paid': MangaFieldIds.pricePaid,
    'location': MangaFieldIds.location,
    'manga.location': MangaFieldIds.location,
    'wishlist': MangaFieldIds.wishlist,
    'manga.wishlist': MangaFieldIds.wishlist,
    'updated': MangaFieldIds.updatedAt,
    'updated_at': MangaFieldIds.updatedAt,
    'manga.updated': MangaFieldIds.updatedAt,
    'manga.updated_at': MangaFieldIds.updatedAt,
    'added': MangaFieldIds.addedAt,
    'added_at': MangaFieldIds.addedAt,
    'manga.added': MangaFieldIds.addedAt,
    'manga.added_at': MangaFieldIds.addedAt,
    'read_status': MangaFieldIds.readStatus,
    'manga.read_status': MangaFieldIds.readStatus,
  };

  static const Map<String, LibrarySortId<MangaKind>> _sortMap = {
    'series': MangaSortIds.series,
    'manga.series': MangaSortIds.series,
    'number': MangaSortIds.volumeNumber,
    'volume_number': MangaSortIds.volumeNumber,
    'manga.number': MangaSortIds.volumeNumber,
    'manga.volume_number': MangaSortIds.volumeNumber,
    'publisher': MangaSortIds.publisher,
    'manga.publisher': MangaSortIds.publisher,
    'status': MangaSortIds.status,
    'manga.status': MangaSortIds.status,
    'title': MangaSortIds.title,
    'manga.title': MangaSortIds.title,
    'release_date': MangaSortIds.releaseDate,
    'manga.release_date': MangaSortIds.releaseDate,
    'rating': MangaSortIds.rating,
    'manga.rating': MangaSortIds.rating,
    'price': MangaSortIds.pricePaid,
    'price_paid': MangaSortIds.pricePaid,
    'manga.price': MangaSortIds.pricePaid,
    'manga.price_paid': MangaSortIds.pricePaid,
    'updated': MangaSortIds.updatedAt,
    'updated_at': MangaSortIds.updatedAt,
    'manga.updated': MangaSortIds.updatedAt,
    'manga.updated_at': MangaSortIds.updatedAt,
  };

  static const Map<String, LibraryGroupId<MangaKind, Object?>> _groupMap = {
    'series': MangaGroupIds.series,
    'manga.series': MangaGroupIds.series,
    'publisher': MangaGroupIds.publisher,
    'manga.publisher': MangaGroupIds.publisher,
    'location': MangaGroupIds.location,
    'manga.location': MangaGroupIds.location,
    'condition': MangaGroupIds.condition,
    'manga.condition': MangaGroupIds.condition,
    'rating': MangaGroupIds.rating,
    'manga.rating': MangaGroupIds.rating,
  };

  @override
  LibraryFieldId<MangaKind, Object?>? decodeColumn(String persisted) =>
      _columnMap[persisted];

  @override
  LibrarySortId<MangaKind>? decodeSort(String persisted) => _sortMap[persisted];

  @override
  LibraryGroupId<MangaKind, Object?>? decodeGroup(String persisted) =>
      _groupMap[persisted];

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<MangaKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
