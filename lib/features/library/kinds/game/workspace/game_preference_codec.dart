import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

final class GamePreferenceCodec
    implements LibraryWorkspacePreferenceCodec<GameKind> {
  const GamePreferenceCodec();

  static const Map<String, LibraryFieldId<GameKind, Object?>> _columnMap = {
    'status': GameFieldIds.status,
    'game.status': GameFieldIds.status,
    'cover': GameFieldIds.cover,
    'game.cover': GameFieldIds.cover,
    'title': GameFieldIds.title,
    'game.title': GameFieldIds.title,
    'platform': GameFieldIds.platform,
    'game.platform': GameFieldIds.platform,
    'publisher': GameFieldIds.publisher,
    'game.publisher': GameFieldIds.publisher,
    'developer': GameFieldIds.developer,
    'game.developer': GameFieldIds.developer,
    'release_date': GameFieldIds.releaseDate,
    'game.release_date': GameFieldIds.releaseDate,
    'barcode': GameFieldIds.barcode,
    'game.barcode': GameFieldIds.barcode,
    'rating': GameFieldIds.rating,
    'game.rating': GameFieldIds.rating,
    'condition': GameFieldIds.condition,
    'game.condition': GameFieldIds.condition,
    'price': GameFieldIds.pricePaid,
    'price_paid': GameFieldIds.pricePaid,
    'game.price': GameFieldIds.pricePaid,
    'game.price_paid': GameFieldIds.pricePaid,
    'location': GameFieldIds.location,
    'game.location': GameFieldIds.location,
    'wishlist': GameFieldIds.wishlist,
    'game.wishlist': GameFieldIds.wishlist,
    'updated': GameFieldIds.updatedAt,
    'updated_at': GameFieldIds.updatedAt,
    'game.updated': GameFieldIds.updatedAt,
    'game.updated_at': GameFieldIds.updatedAt,
    'added': GameFieldIds.addedAt,
    'added_at': GameFieldIds.addedAt,
    'game.added': GameFieldIds.addedAt,
    'game.added_at': GameFieldIds.addedAt,
    'completion_status': GameFieldIds.completionStatus,
    'game.completion_status': GameFieldIds.completionStatus,
  };

  static const Map<String, LibrarySortId<GameKind>> _sortMap = {
    'title': GameSortIds.title,
    'game.title': GameSortIds.title,
    'platform': GameSortIds.platform,
    'game.platform': GameSortIds.platform,
    'publisher': GameSortIds.publisher,
    'game.publisher': GameSortIds.publisher,
    'release_date': GameSortIds.releaseDate,
    'game.release_date': GameSortIds.releaseDate,
    'rating': GameSortIds.rating,
    'game.rating': GameSortIds.rating,
    'price': GameSortIds.pricePaid,
    'price_paid': GameSortIds.pricePaid,
    'game.price': GameSortIds.pricePaid,
    'game.price_paid': GameSortIds.pricePaid,
    'updated': GameSortIds.updatedAt,
    'updated_at': GameSortIds.updatedAt,
    'game.updated': GameSortIds.updatedAt,
    'game.updated_at': GameSortIds.updatedAt,
  };

  static const Map<String, LibraryGroupId<GameKind, Object?>> _groupMap = {
    'platform': GameGroupIds.platform,
    'game.platform': GameGroupIds.platform,
    'publisher': GameGroupIds.publisher,
    'game.publisher': GameGroupIds.publisher,
    'developer': GameGroupIds.developer,
    'game.developer': GameGroupIds.developer,
    'location': GameGroupIds.location,
    'game.location': GameGroupIds.location,
    'condition': GameGroupIds.condition,
    'game.condition': GameGroupIds.condition,
    'rating': GameGroupIds.rating,
    'game.rating': GameGroupIds.rating,
    'completion_status': GameGroupIds.completionStatus,
    'game.completion_status': GameGroupIds.completionStatus,
  };

  @override
  LibraryFieldId<GameKind, Object?>? decodeColumn(String persisted) =>
      _columnMap[persisted];

  @override
  LibrarySortId<GameKind>? decodeSort(String persisted) => _sortMap[persisted];

  @override
  LibraryGroupId<GameKind, Object?>? decodeGroup(String persisted) =>
      _groupMap[persisted];

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<GameKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
