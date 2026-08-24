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
  static const completeness =
      LibraryFieldId<GameKind, String?>('game.completeness');
  static const hasBox = LibraryFieldId<GameKind, bool?>('game.has_box');
  static const hasManual = LibraryFieldId<GameKind, bool?>('game.has_manual');
  static const priceChartingId =
      LibraryFieldId<GameKind, String?>('game.pricecharting_id');
  static const coreRegion =
      LibraryFieldId<GameKind, String?>('game.core_region');
  static const valueLocked =
      LibraryFieldId<GameKind, bool?>('game.value_locked');

  // Rich Game Metadata Fields
  static const franchise = LibraryFieldId<GameKind, String?>('game.franchise');
  static const series = LibraryFieldId<GameKind, String?>('game.series');
  static const ageRating = LibraryFieldId<GameKind, String?>('game.age_rating');
  static const edition = LibraryFieldId<GameKind, String?>('game.edition');
  static const loosePrice = LibraryFieldId<GameKind, int?>('game.loose_price');
  static const cibPrice = LibraryFieldId<GameKind, int?>('game.cib_price');
  static const newPrice = LibraryFieldId<GameKind, int?>('game.new_price');
  static const gradedPrice =
      LibraryFieldId<GameKind, int?>('game.graded_price');
  static const boxOnlyPrice =
      LibraryFieldId<GameKind, int?>('game.box_only_price');
  static const manualOnlyPrice =
      LibraryFieldId<GameKind, int?>('game.manual_only_price');
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
  static const loosePrice = LibrarySortId<GameKind>('game.loose_price');
  static const cibPrice = LibrarySortId<GameKind>('game.cib_price');
}

abstract final class GameGroupIds {
  static const platform = LibraryGroupId<GameKind, String?>('game.platform');
  static const publisher = LibraryGroupId<GameKind, String?>('game.publisher');
  static const developer = LibraryGroupId<GameKind, String?>('game.developer');
  static const franchise = LibraryGroupId<GameKind, String?>('game.franchise');
  static const location = LibraryGroupId<GameKind, String?>('game.location');
  static const condition = LibraryGroupId<GameKind, String?>('game.condition');
  static const rating = LibraryGroupId<GameKind, int?>('game.rating');
  static const completionStatus =
      LibraryGroupId<GameKind, String?>('game.completion_status');
  static const completeness =
      LibraryGroupId<GameKind, String?>('game.completeness');
  static const coreRegion =
      LibraryGroupId<GameKind, String?>('game.core_region');
}

abstract final class GameFacetIds {
  static const platform = LibraryFacetId<GameKind, String>('game.platform');
  static const publisher = LibraryFacetId<GameKind, String>('game.publisher');
  static const developer = LibraryFacetId<GameKind, String>('game.developer');
  static const franchise = LibraryFacetId<GameKind, String>('game.franchise');
  static const genre = LibraryFacetId<GameKind, String>('game.genre');
  static const region = LibraryFacetId<GameKind, String>('game.region');
}
