import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

final class MusicPreferenceCodec
    implements LibraryWorkspacePreferenceCodec<MusicKind> {
  const MusicPreferenceCodec();

  static const Map<String, LibraryFieldId<MusicKind, Object?>> _columnMap = {
    'status': MusicFieldIds.status,
    'music.status': MusicFieldIds.status,
    'cover': MusicFieldIds.cover,
    'music.cover': MusicFieldIds.cover,
    'artist': MusicFieldIds.artist,
    'music.artist': MusicFieldIds.artist,
    'title': MusicFieldIds.title,
    'music.title': MusicFieldIds.title,
    'publisher': MusicFieldIds.publisher,
    'music.publisher': MusicFieldIds.publisher,
    'format': MusicFieldIds.format,
    'music.format': MusicFieldIds.format,
    'release_date': MusicFieldIds.releaseDate,
    'music.release_date': MusicFieldIds.releaseDate,
    'track_count': MusicFieldIds.trackCount,
    'music.track_count': MusicFieldIds.trackCount,
    'barcode': MusicFieldIds.barcode,
    'music.barcode': MusicFieldIds.barcode,
    'rating': MusicFieldIds.rating,
    'music.rating': MusicFieldIds.rating,
    'condition': MusicFieldIds.condition,
    'music.condition': MusicFieldIds.condition,
    'price': MusicFieldIds.pricePaid,
    'price_paid': MusicFieldIds.pricePaid,
    'music.price': MusicFieldIds.pricePaid,
    'music.price_paid': MusicFieldIds.pricePaid,
    'location': MusicFieldIds.location,
    'music.location': MusicFieldIds.location,
    'wishlist': MusicFieldIds.wishlist,
    'music.wishlist': MusicFieldIds.wishlist,
    'updated': MusicFieldIds.updatedAt,
    'updated_at': MusicFieldIds.updatedAt,
    'music.updated': MusicFieldIds.updatedAt,
    'music.updated_at': MusicFieldIds.updatedAt,
    'added': MusicFieldIds.addedAt,
    'added_at': MusicFieldIds.addedAt,
    'music.added': MusicFieldIds.addedAt,
    'music.added_at': MusicFieldIds.addedAt,
  };

  static const Map<String, LibrarySortId<MusicKind>> _sortMap = {
    'artist': MusicSortIds.artist,
    'music.artist': MusicSortIds.artist,
    'title': MusicSortIds.title,
    'music.title': MusicSortIds.title,
    'publisher': MusicSortIds.publisher,
    'music.publisher': MusicSortIds.publisher,
    'release_date': MusicSortIds.releaseDate,
    'music.release_date': MusicSortIds.releaseDate,
    'track_count': MusicSortIds.trackCount,
    'music.track_count': MusicSortIds.trackCount,
    'rating': MusicSortIds.rating,
    'music.rating': MusicSortIds.rating,
    'price': MusicSortIds.pricePaid,
    'price_paid': MusicSortIds.pricePaid,
    'music.price': MusicSortIds.pricePaid,
    'music.price_paid': MusicSortIds.pricePaid,
    'updated': MusicSortIds.updatedAt,
    'updated_at': MusicSortIds.updatedAt,
    'music.updated': MusicSortIds.updatedAt,
    'music.updated_at': MusicSortIds.updatedAt,
  };

  static const Map<String, LibraryGroupId<MusicKind, Object?>> _groupMap = {
    'artist': MusicGroupIds.artist,
    'music.artist': MusicGroupIds.artist,
    'publisher': MusicGroupIds.publisher,
    'music.publisher': MusicGroupIds.publisher,
    'format': MusicGroupIds.format,
    'music.format': MusicGroupIds.format,
    'location': MusicGroupIds.location,
    'music.location': MusicGroupIds.location,
    'condition': MusicGroupIds.condition,
    'music.condition': MusicGroupIds.condition,
    'rating': MusicGroupIds.rating,
    'music.rating': MusicGroupIds.rating,
  };

  @override
  LibraryFieldId<MusicKind, Object?>? decodeColumn(String persisted) =>
      _columnMap[persisted];

  @override
  LibrarySortId<MusicKind>? decodeSort(String persisted) => _sortMap[persisted];

  @override
  LibraryGroupId<MusicKind, Object?>? decodeGroup(String persisted) =>
      _groupMap[persisted];

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<MusicKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
