import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class AnimeFieldIds {
  static const status = LibraryFieldId<AnimeKind, String?>('anime.status');
  static const cover = LibraryFieldId<AnimeKind, String?>('anime.cover');
  static const title = LibraryFieldId<AnimeKind, String>('anime.title');
  static const studio = LibraryFieldId<AnimeKind, String?>('anime.studio');
  static const publisher =
      LibraryFieldId<AnimeKind, String?>('anime.publisher');
  static const releaseDate =
      LibraryFieldId<AnimeKind, DateTime?>('anime.release_date');
  static const releaseYear =
      LibraryFieldId<AnimeKind, int?>('anime.release_year');
  static const episodeCount =
      LibraryFieldId<AnimeKind, int?>('anime.episode_count');
  static const format = LibraryFieldId<AnimeKind, String?>('anime.format');
  static const barcode = LibraryFieldId<AnimeKind, String?>('anime.barcode');
  static const rating = LibraryFieldId<AnimeKind, int?>('anime.rating');
  static const condition =
      LibraryFieldId<AnimeKind, String?>('anime.condition');
  static const pricePaid = LibraryFieldId<AnimeKind, int?>('anime.price_paid');
  static const location = LibraryFieldId<AnimeKind, String?>('anime.location');
  static const wishlist = LibraryFieldId<AnimeKind, bool>('anime.wishlist');
  static const updatedAt =
      LibraryFieldId<AnimeKind, DateTime>('anime.updated_at');
  static const addedAt = LibraryFieldId<AnimeKind, DateTime?>('anime.added_at');
  static const watchStatus =
      LibraryFieldId<AnimeKind, String?>('anime.watch_status');
}

abstract final class AnimeSortIds {
  static const status = LibrarySortId<AnimeKind>('anime.status');
  static const title = LibrarySortId<AnimeKind>('anime.title');
  static const studio = LibrarySortId<AnimeKind>('anime.studio');
  static const publisher = LibrarySortId<AnimeKind>('anime.publisher');
  static const releaseDate = LibrarySortId<AnimeKind>('anime.release_date');
  static const releaseYear = LibrarySortId<AnimeKind>('anime.release_year');
  static const rating = LibrarySortId<AnimeKind>('anime.rating');
  static const pricePaid = LibrarySortId<AnimeKind>('anime.price_paid');
  static const updatedAt = LibrarySortId<AnimeKind>('anime.updated_at');
}

abstract final class AnimeGroupIds {
  static const studio = LibraryGroupId<AnimeKind, String?>('anime.studio');
  static const publisher =
      LibraryGroupId<AnimeKind, String?>('anime.publisher');
  static const format = LibraryGroupId<AnimeKind, String?>('anime.format');
  static const releaseYear =
      LibraryGroupId<AnimeKind, int?>('anime.release_year');
  static const location = LibraryGroupId<AnimeKind, String?>('anime.location');
  static const condition =
      LibraryGroupId<AnimeKind, String?>('anime.condition');
  static const rating = LibraryGroupId<AnimeKind, int?>('anime.rating');
  static const watchStatus =
      LibraryGroupId<AnimeKind, String?>('anime.watch_status');
}

abstract final class AnimeFacetIds {
  static const studio = LibraryFacetId<AnimeKind, String>('anime.studio');
  static const publisher = LibraryFacetId<AnimeKind, String>('anime.publisher');
  static const genre = LibraryFacetId<AnimeKind, String>('anime.genre');
  static const format = LibraryFacetId<AnimeKind, String>('anime.format');
}
