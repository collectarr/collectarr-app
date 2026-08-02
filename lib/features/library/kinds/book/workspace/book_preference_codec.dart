import 'package:collectarr_app/features/library/kinds/book/workspace/book_ids.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';

final class BookPreferenceCodec
    implements LibraryWorkspacePreferenceCodec<BookKind> {
  const BookPreferenceCodec();

  static const Map<String, LibraryFieldId<BookKind, Object?>> _columnMap = {
    'status': BookFieldIds.status,
    'book.status': BookFieldIds.status,
    'cover': BookFieldIds.cover,
    'book.cover': BookFieldIds.cover,
    'title': BookFieldIds.title,
    'book.title': BookFieldIds.title,
    'author': BookFieldIds.author,
    'book.author': BookFieldIds.author,
    'publisher': BookFieldIds.publisher,
    'book.publisher': BookFieldIds.publisher,
    'page_count': BookFieldIds.pageCount,
    'book.page_count': BookFieldIds.pageCount,
    'isbn': BookFieldIds.isbn,
    'book.isbn': BookFieldIds.isbn,
    'condition': BookFieldIds.condition,
    'book.condition': BookFieldIds.condition,
    'location': BookFieldIds.location,
    'book.location': BookFieldIds.location,
    'series': BookFieldIds.series,
    'book.series': BookFieldIds.series,
    'release_date': BookFieldIds.releaseDate,
    'book.release_date': BookFieldIds.releaseDate,
    'read_status': BookFieldIds.readStatus,
    'book.read_status': BookFieldIds.readStatus,
    'rating': BookFieldIds.rating,
    'book.rating': BookFieldIds.rating,
    'price': BookFieldIds.pricePaid,
    'price_paid': BookFieldIds.pricePaid,
    'book.price': BookFieldIds.pricePaid,
    'book.price_paid': BookFieldIds.pricePaid,
    'wishlist': BookFieldIds.wishlist,
    'book.wishlist': BookFieldIds.wishlist,
    'updated': BookFieldIds.updatedAt,
    'updated_at': BookFieldIds.updatedAt,
    'book.updated': BookFieldIds.updatedAt,
    'book.updated_at': BookFieldIds.updatedAt,
    'added': BookFieldIds.addedAt,
    'added_at': BookFieldIds.addedAt,
    'book.added': BookFieldIds.addedAt,
    'book.added_at': BookFieldIds.addedAt,
  };

  static const Map<String, LibrarySortId<BookKind>> _sortMap = {
    'title': BookSortIds.title,
    'book.title': BookSortIds.title,
    'author': BookSortIds.author,
    'book.author': BookSortIds.author,
    'publisher': BookSortIds.publisher,
    'book.publisher': BookSortIds.publisher,
    'release_date': BookSortIds.releaseDate,
    'book.release_date': BookSortIds.releaseDate,
    'page_count': BookSortIds.pageCount,
    'book.page_count': BookSortIds.pageCount,
    'series': BookSortIds.series,
    'book.series': BookSortIds.series,
    'rating': BookSortIds.rating,
    'book.rating': BookSortIds.rating,
    'price': BookSortIds.pricePaid,
    'price_paid': BookSortIds.pricePaid,
    'book.price': BookSortIds.pricePaid,
    'book.price_paid': BookSortIds.pricePaid,
    'updated': BookSortIds.updatedAt,
    'updated_at': BookSortIds.updatedAt,
    'book.updated': BookSortIds.updatedAt,
    'book.updated_at': BookSortIds.updatedAt,
  };

  static const Map<String, LibraryGroupId<BookKind, Object?>> _groupMap = {
    'author': BookGroupIds.author,
    'book.author': BookGroupIds.author,
    'publisher': BookGroupIds.publisher,
    'book.publisher': BookGroupIds.publisher,
    'series': BookGroupIds.series,
    'book.series': BookGroupIds.series,
    'location': BookGroupIds.location,
    'book.location': BookGroupIds.location,
    'condition': BookGroupIds.condition,
    'book.condition': BookGroupIds.condition,
    'rating': BookGroupIds.rating,
    'book.rating': BookGroupIds.rating,
  };

  @override
  LibraryFieldId<BookKind, Object?>? decodeColumn(String persisted) =>
      _columnMap[persisted];

  @override
  LibrarySortId<BookKind>? decodeSort(String persisted) => _sortMap[persisted];

  @override
  LibraryGroupId<BookKind, Object?>? decodeGroup(String persisted) =>
      _groupMap[persisted];

  @override
  String encodeColumn(LibraryFieldIdRuntime id) => id.value;

  @override
  String encodeSort(LibrarySortId<BookKind> id) => id.value;

  @override
  String encodeGroup(LibraryGroupIdRuntime id) => id.value;
}
