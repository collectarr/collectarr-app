import 'package:collectarr_app/features/library/kinds/boardgame/workspace/boardgame_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

final class BoardGamePreferenceCodec
    implements LibraryWorkspacePreferenceCodec<BoardGameKind> {
  const BoardGamePreferenceCodec();

  static const Map<String, LibraryFieldId<BoardGameKind, Object?>> _columnMap =
      {
    'status': BoardGameFieldIds.status,
    'boardgame.status': BoardGameFieldIds.status,
    'cover': BoardGameFieldIds.cover,
    'boardgame.cover': BoardGameFieldIds.cover,
    'title': BoardGameFieldIds.title,
    'boardgame.title': BoardGameFieldIds.title,
    'publisher': BoardGameFieldIds.publisher,
    'boardgame.publisher': BoardGameFieldIds.publisher,
    'designer': BoardGameFieldIds.designer,
    'boardgame.designer': BoardGameFieldIds.designer,
    'player_count': BoardGameFieldIds.playerCount,
    'boardgame.player_count': BoardGameFieldIds.playerCount,
    'play_time': BoardGameFieldIds.playTime,
    'boardgame.play_time': BoardGameFieldIds.playTime,
    'min_age': BoardGameFieldIds.minAge,
    'boardgame.min_age': BoardGameFieldIds.minAge,
    'release_date': BoardGameFieldIds.releaseDate,
    'boardgame.release_date': BoardGameFieldIds.releaseDate,
    'barcode': BoardGameFieldIds.barcode,
    'boardgame.barcode': BoardGameFieldIds.barcode,
    'rating': BoardGameFieldIds.rating,
    'boardgame.rating': BoardGameFieldIds.rating,
    'condition': BoardGameFieldIds.condition,
    'boardgame.condition': BoardGameFieldIds.condition,
    'price': BoardGameFieldIds.pricePaid,
    'price_paid': BoardGameFieldIds.pricePaid,
    'boardgame.price': BoardGameFieldIds.pricePaid,
    'boardgame.price_paid': BoardGameFieldIds.pricePaid,
    'location': BoardGameFieldIds.location,
    'boardgame.location': BoardGameFieldIds.location,
    'wishlist': BoardGameFieldIds.wishlist,
    'boardgame.wishlist': BoardGameFieldIds.wishlist,
    'updated': BoardGameFieldIds.updatedAt,
    'updated_at': BoardGameFieldIds.updatedAt,
    'boardgame.updated': BoardGameFieldIds.updatedAt,
    'boardgame.updated_at': BoardGameFieldIds.updatedAt,
    'added': BoardGameFieldIds.addedAt,
    'added_at': BoardGameFieldIds.addedAt,
    'boardgame.added': BoardGameFieldIds.addedAt,
    'boardgame.added_at': BoardGameFieldIds.addedAt,
  };

  static const Map<String, LibrarySortId<BoardGameKind>> _sortMap = {
    'title': BoardGameSortIds.title,
    'boardgame.title': BoardGameSortIds.title,
    'publisher': BoardGameSortIds.publisher,
    'boardgame.publisher': BoardGameSortIds.publisher,
    'designer': BoardGameSortIds.designer,
    'boardgame.designer': BoardGameSortIds.designer,
    'release_date': BoardGameSortIds.releaseDate,
    'boardgame.release_date': BoardGameSortIds.releaseDate,
    'play_time': BoardGameSortIds.playTime,
    'boardgame.play_time': BoardGameSortIds.playTime,
    'rating': BoardGameSortIds.rating,
    'boardgame.rating': BoardGameSortIds.rating,
    'price': BoardGameSortIds.pricePaid,
    'price_paid': BoardGameSortIds.pricePaid,
    'boardgame.price': BoardGameSortIds.pricePaid,
    'boardgame.price_paid': BoardGameSortIds.pricePaid,
    'updated': BoardGameSortIds.updatedAt,
    'updated_at': BoardGameSortIds.updatedAt,
    'boardgame.updated': BoardGameSortIds.updatedAt,
    'boardgame.updated_at': BoardGameSortIds.updatedAt,
  };

  static const Map<String, LibraryGroupId<BoardGameKind, Object?>> _groupMap = {
    'publisher': BoardGameGroupIds.publisher,
    'boardgame.publisher': BoardGameGroupIds.publisher,
    'designer': BoardGameGroupIds.designer,
    'boardgame.designer': BoardGameGroupIds.designer,
    'location': BoardGameGroupIds.location,
    'boardgame.location': BoardGameGroupIds.location,
    'condition': BoardGameGroupIds.condition,
    'boardgame.condition': BoardGameGroupIds.condition,
    'rating': BoardGameGroupIds.rating,
    'boardgame.rating': BoardGameGroupIds.rating,
    'player_count': BoardGameGroupIds.playerCount,
    'boardgame.player_count': BoardGameGroupIds.playerCount,
  };

  @override
  LibraryFieldId<BoardGameKind, Object?>? decodeColumn(String persisted) =>
      _columnMap[persisted];

  @override
  LibrarySortId<BoardGameKind>? decodeSort(String persisted) =>
      _sortMap[persisted];

  @override
  LibraryGroupId<BoardGameKind, Object?>? decodeGroup(String persisted) =>
      _groupMap[persisted];

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<BoardGameKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
