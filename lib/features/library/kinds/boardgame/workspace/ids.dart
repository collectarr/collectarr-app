import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config/boardgame_field_identities.dart';

abstract final class BoardGameFieldIds {
  static const status =
      LibraryFieldId<BoardGameKind, String?>('boardgame.status');
  static const cover =
      LibraryFieldId<BoardGameKind, String?>('boardgame.cover');
  static const title = LibraryFieldId<BoardGameKind, String>('boardgame.title');
  static const publisher = LibraryFieldId<BoardGameKind, String?>(
      BoardGameFieldIdentities.publisherId);
  static const designer =
      LibraryFieldId<BoardGameKind, String?>('boardgame.designer');
  static const playerCount =
      LibraryFieldId<BoardGameKind, String?>('boardgame.player_count');
  static const playTime =
      LibraryFieldId<BoardGameKind, int?>('boardgame.play_time');
  static const minAge =
      LibraryFieldId<BoardGameKind, int?>('boardgame.min_age');
  static const releaseDate = LibraryFieldId<BoardGameKind, DateTime?>(
      BoardGameFieldIdentities.releaseDateId);
  static const barcode = LibraryFieldId<BoardGameKind, String?>(
      BoardGameFieldIdentities.barcodeId);
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
  static const minPlayers = LibraryFieldId<BoardGameKind, int?>(
      BoardGameFieldIdentities.minPlayersId);
  static const maxPlayers = LibraryFieldId<BoardGameKind, int?>(
      BoardGameFieldIdentities.maxPlayersId);
  static const bestPlayers = LibraryFieldId<BoardGameKind, String?>(
      BoardGameFieldIdentities.bestPlayersId);
  static const recommendedPlayers = LibraryFieldId<BoardGameKind, String?>(
      BoardGameFieldIdentities.recommendedPlayersId);
  static const minPlaytimeMinutes = LibraryFieldId<BoardGameKind, int?>(
      BoardGameFieldIdentities.minPlaytimeMinutesId);
  static const maxPlaytimeMinutes = LibraryFieldId<BoardGameKind, int?>(
      BoardGameFieldIdentities.maxPlaytimeMinutesId);
  static const complexityWeight = LibraryFieldId<BoardGameKind, double?>(
      BoardGameFieldIdentities.complexityWeightId);
  static const bggRating = LibraryFieldId<BoardGameKind, double?>(
      BoardGameFieldIdentities.bggRatingId);
  static const bggRank =
      LibraryFieldId<BoardGameKind, int?>(BoardGameFieldIdentities.bggRankId);
  static const expansionFor = LibraryFieldId<BoardGameKind, String?>(
      BoardGameFieldIdentities.expansionForId);
}

abstract final class BoardGameSortIds {
  static const status = LibrarySortId<BoardGameKind>('boardgame.status');
  static const title = LibrarySortId<BoardGameKind>('boardgame.title');
  static const publisher =
      LibrarySortId<BoardGameKind>(BoardGameFieldIdentities.publisherId);
  static const designer = LibrarySortId<BoardGameKind>('boardgame.designer');
  static const releaseDate =
      LibrarySortId<BoardGameKind>(BoardGameFieldIdentities.releaseDateId);
  static const playTime = LibrarySortId<BoardGameKind>('boardgame.play_time');
  static const rating = LibrarySortId<BoardGameKind>('boardgame.rating');
  static const pricePaid = LibrarySortId<BoardGameKind>('boardgame.price_paid');
  static const updatedAt = LibrarySortId<BoardGameKind>('boardgame.updated_at');
  static const complexityWeight =
      LibrarySortId<BoardGameKind>(BoardGameFieldIdentities.complexityWeightId);
  static const bggRating =
      LibrarySortId<BoardGameKind>(BoardGameFieldIdentities.bggRatingId);
  static const bggRank =
      LibrarySortId<BoardGameKind>(BoardGameFieldIdentities.bggRankId);
}

abstract final class BoardGameGroupIds {
  static const publisher = LibraryGroupId<BoardGameKind, String?>(
      BoardGameFieldIdentities.publisherId);
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
  static const bestPlayers = LibraryGroupId<BoardGameKind, String?>(
      BoardGameFieldIdentities.bestPlayersId);
}

abstract final class BoardGameFacetIds {
  static const publisher = LibraryFacetId<BoardGameKind, String>(
      BoardGameFieldIdentities.publisherId);
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
