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

  // Rich BoardGame Metadata Fields
  static const minPlayers =
      LibraryFieldId<BoardGameKind, int?>('boardgame.min_players');
  static const maxPlayers =
      LibraryFieldId<BoardGameKind, int?>('boardgame.max_players');
  static const bestPlayers =
      LibraryFieldId<BoardGameKind, String?>('boardgame.best_players');
  static const recommendedPlayers =
      LibraryFieldId<BoardGameKind, String?>('boardgame.recommended_players');
  static const minPlaytimeMinutes =
      LibraryFieldId<BoardGameKind, int?>('boardgame.min_playtime_minutes');
  static const maxPlaytimeMinutes =
      LibraryFieldId<BoardGameKind, int?>('boardgame.max_playtime_minutes');
  static const complexityWeight =
      LibraryFieldId<BoardGameKind, double?>('boardgame.complexity_weight');
  static const bggRating =
      LibraryFieldId<BoardGameKind, double?>('boardgame.bgg_rating');
  static const bggRank =
      LibraryFieldId<BoardGameKind, int?>('boardgame.bgg_rank');
  static const expansionFor =
      LibraryFieldId<BoardGameKind, String?>('boardgame.expansion_for');
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
  static const complexityWeight =
      LibrarySortId<BoardGameKind>('boardgame.complexity_weight');
  static const bggRating = LibrarySortId<BoardGameKind>('boardgame.bgg_rating');
  static const bggRank = LibrarySortId<BoardGameKind>('boardgame.bgg_rank');
}

abstract final class BoardGameGroupIds {
  static const publisher =
      LibraryGroupId<BoardGameKind, String?>('boardgame.publisher');
  static const designer =
      LibraryGroupId<BoardGameKind, String?>('boardgame.designer');
  static const location = LibraryGroupId<BoardGameKind, String?>(
    'boardgame.location',
    semantic: LibraryGroupSemantic.location,
  );
  static const condition =
      LibraryGroupId<BoardGameKind, String?>('boardgame.condition');
  static const rating = LibraryGroupId<BoardGameKind, int?>('boardgame.rating');
  static const playerCount =
      LibraryGroupId<BoardGameKind, String?>('boardgame.player_count');
  static const bestPlayers =
      LibraryGroupId<BoardGameKind, String?>('boardgame.best_players');
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
  static const family =
      LibraryFacetId<BoardGameKind, String>('boardgame.family');
  static const theme = LibraryFacetId<BoardGameKind, String>('boardgame.theme');
}
