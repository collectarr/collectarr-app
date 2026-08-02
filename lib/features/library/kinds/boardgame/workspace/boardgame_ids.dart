import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class BoardGameFieldIds {
  static const status =
      LibraryFieldId<BoardGameKind, String?>('boardgame.status');
  static const cover =
      LibraryFieldId<BoardGameKind, String?>('boardgame.cover');
  static const title = LibraryFieldId<BoardGameKind, String>('boardgame.title');
  static const publisher =
      LibraryFieldId<BoardGameKind, String?>('boardgame.publisher');
  static const designer =
      LibraryFieldId<BoardGameKind, String?>('boardgame.designer');
  static const playerCount =
      LibraryFieldId<BoardGameKind, String?>('boardgame.player_count');
  static const playTime =
      LibraryFieldId<BoardGameKind, int?>('boardgame.play_time');
  static const minAge =
      LibraryFieldId<BoardGameKind, int?>('boardgame.min_age');
  static const releaseDate =
      LibraryFieldId<BoardGameKind, DateTime?>('boardgame.release_date');
  static const barcode =
      LibraryFieldId<BoardGameKind, String?>('boardgame.barcode');
  static const rating = LibraryFieldId<BoardGameKind, int?>('boardgame.rating');
  static const condition =
      LibraryFieldId<BoardGameKind, String?>('boardgame.condition');
  static const pricePaid =
      LibraryFieldId<BoardGameKind, int?>('boardgame.price_paid');
  static const location =
      LibraryFieldId<BoardGameKind, String?>('boardgame.location');
  static const wishlist =
      LibraryFieldId<BoardGameKind, bool>('boardgame.wishlist');
  static const updatedAt =
      LibraryFieldId<BoardGameKind, DateTime>('boardgame.updated_at');
  static const addedAt =
      LibraryFieldId<BoardGameKind, DateTime?>('boardgame.added_at');
}

abstract final class BoardGameSortIds {
  static const status = LibrarySortId<BoardGameKind>('boardgame.status');
  static const title = LibrarySortId<BoardGameKind>('boardgame.title');
  static const publisher = LibrarySortId<BoardGameKind>('boardgame.publisher');
  static const designer = LibrarySortId<BoardGameKind>('boardgame.designer');
  static const releaseDate =
      LibrarySortId<BoardGameKind>('boardgame.release_date');
  static const playTime = LibrarySortId<BoardGameKind>('boardgame.play_time');
  static const rating = LibrarySortId<BoardGameKind>('boardgame.rating');
  static const pricePaid = LibrarySortId<BoardGameKind>('boardgame.price_paid');
  static const updatedAt = LibrarySortId<BoardGameKind>('boardgame.updated_at');
}

abstract final class BoardGameGroupIds {
  static const publisher =
      LibraryGroupId<BoardGameKind, String?>('boardgame.publisher');
  static const designer =
      LibraryGroupId<BoardGameKind, String?>('boardgame.designer');
  static const location =
      LibraryGroupId<BoardGameKind, String?>('boardgame.location');
  static const condition =
      LibraryGroupId<BoardGameKind, String?>('boardgame.condition');
  static const rating = LibraryGroupId<BoardGameKind, int?>('boardgame.rating');
  static const playerCount =
      LibraryGroupId<BoardGameKind, String?>('boardgame.player_count');
}

abstract final class BoardGameFacetIds {
  static const publisher =
      LibraryFacetId<BoardGameKind, String>('boardgame.publisher');
  static const designer =
      LibraryFacetId<BoardGameKind, String>('boardgame.designer');
  static const mechanic =
      LibraryFacetId<BoardGameKind, String>('boardgame.mechanic');
  static const category =
      LibraryFacetId<BoardGameKind, String>('boardgame.category');
}
