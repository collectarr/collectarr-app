import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class MangaFieldIds {
  static const status = LibraryFieldId<MangaKind, String?>('manga.status');
  static const cover = LibraryFieldId<MangaKind, String?>('manga.cover');
  static const series = LibraryFieldId<MangaKind, String?>('manga.series');
  static const title = LibraryFieldId<MangaKind, String>('manga.title');
  static const volumeNumber =
      LibraryFieldId<MangaKind, String?>('manga.volume_number');
  static const publisher =
      LibraryFieldId<MangaKind, String?>('manga.publisher');
  static const releaseDate =
      LibraryFieldId<MangaKind, DateTime?>('manga.release_date');
  static const barcode = LibraryFieldId<MangaKind, String?>('manga.barcode');
  static const rating = LibraryFieldId<MangaKind, int?>('manga.rating');
  static const condition =
      LibraryFieldId<MangaKind, String?>('manga.condition');
  static const pricePaid = LibraryFieldId<MangaKind, int?>('manga.price_paid');
  static const location = LibraryFieldId<MangaKind, String?>('manga.location');
  static const wishlist = LibraryFieldId<MangaKind, bool>('manga.wishlist');
  static const updatedAt =
      LibraryFieldId<MangaKind, DateTime>('manga.updated_at');
  static const addedAt = LibraryFieldId<MangaKind, DateTime?>('manga.added_at');
  static const readStatus =
      LibraryFieldId<MangaKind, String?>('manga.read_status');
}

abstract final class MangaSortIds {
  static const series = LibrarySortId<MangaKind>('manga.series');
  static const volumeNumber = LibrarySortId<MangaKind>('manga.volume_number');
  static const publisher = LibrarySortId<MangaKind>('manga.publisher');
  static const status = LibrarySortId<MangaKind>('manga.status');
  static const title = LibrarySortId<MangaKind>('manga.title');
  static const releaseDate = LibrarySortId<MangaKind>('manga.release_date');
  static const rating = LibrarySortId<MangaKind>('manga.rating');
  static const pricePaid = LibrarySortId<MangaKind>('manga.price_paid');
  static const updatedAt = LibrarySortId<MangaKind>('manga.updated_at');
}

abstract final class MangaGroupIds {
  static const series = LibraryGroupId<MangaKind, String?>('manga.series');
  static const publisher =
      LibraryGroupId<MangaKind, String?>('manga.publisher');
  static const location = LibraryGroupId<MangaKind, String?>('manga.location');
  static const condition =
      LibraryGroupId<MangaKind, String?>('manga.condition');
  static const rating = LibraryGroupId<MangaKind, int?>('manga.rating');
}

abstract final class MangaFacetIds {
  static const publisher = LibraryFacetId<MangaKind, String>('manga.publisher');
  static const genre = LibraryFacetId<MangaKind, String>('manga.genre');
}
