import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class GameFieldIds {
  static const status = LibraryFieldId<GameKind, String?>('game.status');
  static const cover = LibraryFieldId<GameKind, String?>('game.cover');
  static const title = LibraryFieldId<GameKind, String>('game.title');
  static const platform = LibraryFieldId<GameKind, String?>('game.platform');
  static const publisher = LibraryFieldId<GameKind, String?>('game.publisher');
  static const developer = LibraryFieldId<GameKind, String?>('game.developer');
  static const releaseDate =
      LibraryFieldId<GameKind, DateTime?>('game.release_date');
  static const barcode = LibraryFieldId<GameKind, String?>('game.barcode');
  static const rating = LibraryFieldId<GameKind, int?>('game.rating');
  static const condition = LibraryFieldId<GameKind, String?>('game.condition');
  static const pricePaid = LibraryFieldId<GameKind, int?>('game.price_paid');
  static const location = LibraryFieldId<GameKind, String?>('game.location');
  static const wishlist = LibraryFieldId<GameKind, bool>('game.wishlist');
  static const updatedAt =
      LibraryFieldId<GameKind, DateTime>('game.updated_at');
  static const addedAt = LibraryFieldId<GameKind, DateTime?>('game.added_at');
  static const completionStatus =
      LibraryFieldId<GameKind, String?>('game.completion_status');
}

abstract final class GameSortIds {
  static const status = LibrarySortId<GameKind>('game.status');
  static const title = LibrarySortId<GameKind>('game.title');
  static const platform = LibrarySortId<GameKind>('game.platform');
  static const publisher = LibrarySortId<GameKind>('game.publisher');
  static const releaseDate = LibrarySortId<GameKind>('game.release_date');
  static const rating = LibrarySortId<GameKind>('game.rating');
  static const pricePaid = LibrarySortId<GameKind>('game.price_paid');
  static const updatedAt = LibrarySortId<GameKind>('game.updated_at');
}

abstract final class GameGroupIds {
  static const platform = LibraryGroupId<GameKind, String?>('game.platform');
  static const publisher = LibraryGroupId<GameKind, String?>('game.publisher');
  static const developer = LibraryGroupId<GameKind, String?>('game.developer');
  static const location = LibraryGroupId<GameKind, String?>('game.location');
  static const condition = LibraryGroupId<GameKind, String?>('game.condition');
  static const rating = LibraryGroupId<GameKind, int?>('game.rating');
  static const completionStatus =
      LibraryGroupId<GameKind, String?>('game.completion_status');
}

abstract final class GameFacetIds {
  static const platform = LibraryFacetId<GameKind, String>('game.platform');
  static const publisher = LibraryFacetId<GameKind, String>('game.publisher');
  static const genre = LibraryFacetId<GameKind, String>('game.genre');
}
