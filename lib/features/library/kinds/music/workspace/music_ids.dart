import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class MusicFieldIds {
  static const status = LibraryFieldId<MusicKind, String?>('music.status');
  static const cover = LibraryFieldId<MusicKind, String?>('music.cover');
  static const artist = LibraryFieldId<MusicKind, String?>('music.artist');
  static const title = LibraryFieldId<MusicKind, String>('music.title');
  static const publisher =
      LibraryFieldId<MusicKind, String?>('music.publisher');
  static const genre = LibraryFieldId<MusicKind, String?>('music.genre');
  static const releaseCount =
      LibraryFieldId<MusicKind, int?>('music.release_count');
  static const format = LibraryFieldId<MusicKind, String?>('music.format');
  static const releaseType =
      LibraryFieldId<MusicKind, String?>('music.release_type');
  static const releaseStatus =
      LibraryFieldId<MusicKind, String?>('music.release_status');
  static const language = LibraryFieldId<MusicKind, String?>('music.language');
  static const packaging =
      LibraryFieldId<MusicKind, String?>('music.packaging');
  static const releaseDate =
      LibraryFieldId<MusicKind, DateTime?>('music.release_date');
  static const trackCount =
      LibraryFieldId<MusicKind, int?>('music.track_count');
  static const barcode = LibraryFieldId<MusicKind, String?>('music.barcode');
  static const rating = LibraryFieldId<MusicKind, int?>('music.rating');
  static const condition =
      LibraryFieldId<MusicKind, String?>('music.condition');
  static const pricePaid = LibraryFieldId<MusicKind, int?>('music.price_paid');
  static const location = LibraryFieldId<MusicKind, String?>('music.location');
  static const wishlist = LibraryFieldId<MusicKind, bool>('music.wishlist');
  static const updatedAt =
      LibraryFieldId<MusicKind, DateTime>('music.updated_at');
  static const addedAt = LibraryFieldId<MusicKind, DateTime?>('music.added_at');

  // Rich Music Metadata Fields
  static const catalogNumber =
      LibraryFieldId<MusicKind, String?>('music.catalog_number');
  static const country = LibraryFieldId<MusicKind, String?>('music.country');
  static const discCount = LibraryFieldId<MusicKind, int?>('music.disc_count');
  static const signedBy = LibraryFieldId<MusicKind, String?>('music.signed_by');
  static const grade = LibraryFieldId<MusicKind, String?>('music.grade');
  static const storage = LibraryFieldId<MusicKind, String?>('music.storage');
  static const purchaseDate =
      LibraryFieldId<MusicKind, DateTime?>('music.purchase_date');
  static const marketValue =
      LibraryFieldId<MusicKind, int?>('music.market_value');
  static const indexNumber =
      LibraryFieldId<MusicKind, int?>('music.index_number');
  static const lastCleaned =
      LibraryFieldId<MusicKind, DateTime?>('music.last_cleaned');
}

abstract final class MusicSortIds {
  static const status = LibrarySortId<MusicKind>('music.status');
  static const artist = LibrarySortId<MusicKind>('music.artist');
  static const title = LibrarySortId<MusicKind>('music.title');
  static const publisher = LibrarySortId<MusicKind>('music.publisher');
  static const releaseDate = LibrarySortId<MusicKind>('music.release_date');
  static const trackCount = LibrarySortId<MusicKind>('music.track_count');
  static const rating = LibrarySortId<MusicKind>('music.rating');
  static const pricePaid = LibrarySortId<MusicKind>('music.price_paid');
  static const updatedAt = LibrarySortId<MusicKind>('music.updated_at');
  static const discCount = LibrarySortId<MusicKind>('music.disc_count');
}

abstract final class MusicGroupIds {
  static const artist = LibraryGroupId<MusicKind, String?>('music.artist');
  static const publisher =
      LibraryGroupId<MusicKind, String?>('music.publisher');
  static const genre = LibraryGroupId<MusicKind, String?>('music.genre');
  static const format = LibraryGroupId<MusicKind, String?>('music.format');
  static const location = LibraryGroupId<MusicKind, String?>(
    'music.location',
    semantic: LibraryGroupSemantic.location,
  );
  static const condition =
      LibraryGroupId<MusicKind, String?>('music.condition');
  static const rating = LibraryGroupId<MusicKind, int?>('music.rating');
  static const country = LibraryGroupId<MusicKind, String?>('music.country');
}

abstract final class MusicFacetIds {
  static const artist = LibraryFacetId<MusicKind, String>('music.artist');
  static const publisher = LibraryFacetId<MusicKind, String>('music.publisher');
  static const genre = LibraryFacetId<MusicKind, String>('music.genre');
  static const format = LibraryFacetId<MusicKind, String>('music.format');
  static const country = LibraryFacetId<MusicKind, String>('music.country');
}
