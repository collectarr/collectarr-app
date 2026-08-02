import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class TvFieldIds {
  static const status = LibraryFieldId<TvKind, String?>('tv.status');
  static const cover = LibraryFieldId<TvKind, String?>('tv.cover');
  static const title = LibraryFieldId<TvKind, String>('tv.title');
  static const series = LibraryFieldId<TvKind, String?>('tv.series');
  static const network = LibraryFieldId<TvKind, String?>('tv.network');
  static const creator = LibraryFieldId<TvKind, String?>('tv.creator');
  static const releaseDate =
      LibraryFieldId<TvKind, DateTime?>('tv.release_date');
  static const releaseYear = LibraryFieldId<TvKind, int?>('tv.release_year');
  static const seasonCount = LibraryFieldId<TvKind, int?>('tv.season_count');
  static const episodeCount = LibraryFieldId<TvKind, int?>('tv.episode_count');
  static const barcode = LibraryFieldId<TvKind, String?>('tv.barcode');
  static const rating = LibraryFieldId<TvKind, int?>('tv.rating');
  static const condition = LibraryFieldId<TvKind, String?>('tv.condition');
  static const pricePaid = LibraryFieldId<TvKind, int?>('tv.price_paid');
  static const location = LibraryFieldId<TvKind, String?>('tv.location');
  static const wishlist = LibraryFieldId<TvKind, bool>('tv.wishlist');
  static const updatedAt = LibraryFieldId<TvKind, DateTime>('tv.updated_at');
  static const addedAt = LibraryFieldId<TvKind, DateTime?>('tv.added_at');
  static const watchStatus = LibraryFieldId<TvKind, String?>('tv.watch_status');
}

abstract final class TvSortIds {
  static const status = LibrarySortId<TvKind>('tv.status');
  static const title = LibrarySortId<TvKind>('tv.title');
  static const series = LibrarySortId<TvKind>('tv.series');
  static const network = LibrarySortId<TvKind>('tv.network');
  static const releaseDate = LibrarySortId<TvKind>('tv.release_date');
  static const releaseYear = LibrarySortId<TvKind>('tv.release_year');
  static const rating = LibrarySortId<TvKind>('tv.rating');
  static const pricePaid = LibrarySortId<TvKind>('tv.price_paid');
  static const updatedAt = LibrarySortId<TvKind>('tv.updated_at');
}

abstract final class TvGroupIds {
  static const series = LibraryGroupId<TvKind, String?>('tv.series');
  static const network = LibraryGroupId<TvKind, String?>('tv.network');
  static const creator = LibraryGroupId<TvKind, String?>('tv.creator');
  static const releaseYear = LibraryGroupId<TvKind, int?>('tv.release_year');
  static const location = LibraryGroupId<TvKind, String?>('tv.location');
  static const condition = LibraryGroupId<TvKind, String?>('tv.condition');
  static const rating = LibraryGroupId<TvKind, int?>('tv.rating');
  static const watchStatus = LibraryGroupId<TvKind, String?>('tv.watch_status');
}

abstract final class TvFacetIds {
  static const network = LibraryFacetId<TvKind, String>('tv.network');
  static const genre = LibraryFacetId<TvKind, String>('tv.genre');
  static const creator = LibraryFacetId<TvKind, String>('tv.creator');
}
