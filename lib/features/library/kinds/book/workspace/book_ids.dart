import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

abstract final class BookFieldIds {
  static const status = LibraryFieldId<BookKind, String?>('book.status');
  static const cover = LibraryFieldId<BookKind, String?>('book.cover');
  static const title = LibraryFieldId<BookKind, String>('book.title');
  static const author = LibraryFieldId<BookKind, String?>('book.author');
  static const publisher = LibraryFieldId<BookKind, String?>('book.publisher');
  static const pageCount = LibraryFieldId<BookKind, int?>('book.page_count');
  static const isbn = LibraryFieldId<BookKind, String?>('book.isbn');
  static const condition = LibraryFieldId<BookKind, String?>('book.condition');
  static const location = LibraryFieldId<BookKind, String?>('book.location');
  static const series = LibraryFieldId<BookKind, String?>('book.series');
  static const releaseDate =
      LibraryFieldId<BookKind, DateTime?>('book.release_date');
  static const readStatus =
      LibraryFieldId<BookKind, String?>('book.read_status');
  static const rating = LibraryFieldId<BookKind, int?>('book.rating');
  static const pricePaid = LibraryFieldId<BookKind, int?>('book.price_paid');
  static const wishlist = LibraryFieldId<BookKind, bool>('book.wishlist');
  static const updatedAt =
      LibraryFieldId<BookKind, DateTime>('book.updated_at');
  static const addedAt = LibraryFieldId<BookKind, DateTime?>('book.added_at');
}

abstract final class BookSortIds {
  static const status = LibrarySortId<BookKind>('book.status');
  static const title = LibrarySortId<BookKind>('book.title');
  static const author = LibrarySortId<BookKind>('book.author');
  static const publisher = LibrarySortId<BookKind>('book.publisher');
  static const releaseDate = LibrarySortId<BookKind>('book.release_date');
  static const pageCount = LibrarySortId<BookKind>('book.page_count');
  static const series = LibrarySortId<BookKind>('book.series');
  static const rating = LibrarySortId<BookKind>('book.rating');
  static const pricePaid = LibrarySortId<BookKind>('book.price_paid');
  static const updatedAt = LibrarySortId<BookKind>('book.updated_at');
}

abstract final class BookGroupIds {
  static const author = LibraryGroupId<BookKind, String?>('book.author');
  static const publisher = LibraryGroupId<BookKind, String?>('book.publisher');
  static const series = LibraryGroupId<BookKind, String?>('book.series');
  static const location = LibraryGroupId<BookKind, String?>('book.location');
  static const condition = LibraryGroupId<BookKind, String?>('book.condition');
  static const rating = LibraryGroupId<BookKind, int?>('book.rating');
}

abstract final class BookFacetIds {
  static const author = LibraryFacetId<BookKind, String>('book.author');
  static const publisher = LibraryFacetId<BookKind, String>('book.publisher');
  static const genre = LibraryFacetId<BookKind, String>('book.genre');
}
