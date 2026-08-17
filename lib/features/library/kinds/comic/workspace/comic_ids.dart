import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class ComicFieldIds {
  static const status = LibraryFieldId<ComicKind, String?>('comic.status');
  static const cover = LibraryFieldId<ComicKind, String?>('comic.cover');
  static const series = LibraryFieldId<ComicKind, String?>('comic.series');
  static const title = LibraryFieldId<ComicKind, String>('comic.title');
  static const issueNumber =
      LibraryFieldId<ComicKind, String?>('comic.issue_number');
  static const publisher =
      LibraryFieldId<ComicKind, String?>('comic.publisher');
  static const releaseDate =
      LibraryFieldId<ComicKind, DateTime?>('comic.release_date');
  static const barcode = LibraryFieldId<ComicKind, String?>('comic.barcode');
  static const rating = LibraryFieldId<ComicKind, int?>('comic.rating');
  static const condition =
      LibraryFieldId<ComicKind, String?>('comic.condition');
  static const pricePaid = LibraryFieldId<ComicKind, int?>('comic.price_paid');
  static const location = LibraryFieldId<ComicKind, String?>('comic.location');
  static const wishlist = LibraryFieldId<ComicKind, bool>('comic.wishlist');
  static const updatedAt =
      LibraryFieldId<ComicKind, DateTime>('comic.updated_at');
  static const addedAt = LibraryFieldId<ComicKind, DateTime?>('comic.added_at');
  static const readStatus =
      LibraryFieldId<ComicKind, String?>('comic.read_status');
  static const grade = LibraryFieldId<ComicKind, String?>('comic.grade');
  static const keyComic = LibraryFieldId<ComicKind, bool>('comic.key_comic');
}

abstract final class ComicSortIds {
  static const series = LibrarySortId<ComicKind>('comic.series');
  static const issueNumber = LibrarySortId<ComicKind>('comic.issue_number');
  static const publisher = LibrarySortId<ComicKind>('comic.publisher');
  static const status = LibrarySortId<ComicKind>('comic.status');
  static const title = LibrarySortId<ComicKind>('comic.title');
  static const releaseDate = LibrarySortId<ComicKind>('comic.release_date');
  static const condition = LibrarySortId<ComicKind>('comic.condition');
  static const rating = LibrarySortId<ComicKind>('comic.rating');
  static const pricePaid = LibrarySortId<ComicKind>('comic.price_paid');
  static const updatedAt = LibrarySortId<ComicKind>('comic.updated_at');
}

abstract final class ComicGroupIds {
  static const series = LibraryGroupId<ComicKind, String?>('comic.series');
  static const publisher =
      LibraryGroupId<ComicKind, String?>('comic.publisher');
  static const location = LibraryGroupId<ComicKind, String?>('comic.location');
  static const condition =
      LibraryGroupId<ComicKind, String?>('comic.condition');
  static const rating = LibraryGroupId<ComicKind, int?>('comic.rating');
  static const creator = LibraryGroupId<ComicKind, String?>('comic.creator');
  static const character =
      LibraryGroupId<ComicKind, String?>('comic.character');
  static const storyArc = LibraryGroupId<ComicKind, String?>('comic.story_arc');
}

abstract final class ComicFacetIds {
  static const publisher = LibraryFacetId<ComicKind, String>('comic.publisher');
  static const genre = LibraryFacetId<ComicKind, String>('comic.genre');
  static const character = LibraryFacetId<ComicKind, String>('comic.character');
  static const storyArc = LibraryFacetId<ComicKind, String>('comic.story_arc');
}
