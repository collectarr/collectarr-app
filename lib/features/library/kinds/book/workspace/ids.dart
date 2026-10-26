import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/kinds/book/config/book_field_identities.dart';

abstract final class BookFieldIds {
  static const status = LibraryFieldId<BookKind, String?>('book.status');
  static const cover = LibraryFieldId<BookKind, String?>('book.cover');
  static const title = LibraryFieldId<BookKind, String>('book.title');
  static const author = LibraryFieldId<BookKind, String?>('book.author');
  static const publisher =
      LibraryFieldId<BookKind, String?>(BookFieldIdentities.publisherId);
  static const pageCount =
      LibraryFieldId<BookKind, int?>(BookFieldIdentities.pageCountId);
  static const isbn =
      LibraryFieldId<BookKind, String?>(BookFieldIdentities.isbnId);
  static const condition = LibraryFieldId<BookKind, String?>('book.condition');
  static const location = LibraryFieldId<BookKind, String?>('book.location');
  static const series =
      LibraryFieldId<BookKind, String?>(BookFieldIdentities.seriesId);
  static const releaseDate =
      LibraryFieldId<BookKind, DateTime?>(BookFieldIdentities.releaseDateId);
  static const readStatus =
      LibraryFieldId<BookKind, String?>('book.read_status');
  static const rating = LibraryFieldId<BookKind, int?>('book.rating');
  static const pricePaid = LibraryFieldId<BookKind, int?>('book.price_paid');
  static const wishlist = LibraryFieldId<BookKind, bool>('book.wishlist');
  static const updatedAt =
      LibraryFieldId<BookKind, DateTime>('book.updated_at');
  static const addedAt = LibraryFieldId<BookKind, DateTime?>('book.added_at');

  // Rich Book Metadata Fields
  static const subtitle =
      LibraryFieldId<BookKind, String?>(BookFieldIdentities.subtitleId);
  static const format =
      LibraryFieldId<BookKind, String?>(BookFieldIdentities.formatId);
  static const translator =
      LibraryFieldId<BookKind, String?>('book.translator');
  static const editor = LibraryFieldId<BookKind, String?>('book.editor');
  static const illustrator =
      LibraryFieldId<BookKind, String?>('book.illustrator');
  static const coverArtist =
      LibraryFieldId<BookKind, String?>('book.cover_artist');
  static const signedBy = LibraryFieldId<BookKind, String?>('book.signed_by');
}

abstract final class BookSortIds {
  static const status = LibrarySortId<BookKind>('book.status');
  static const title = LibrarySortId<BookKind>('book.title');
  static const author = LibrarySortId<BookKind>('book.author');
  static const publisher =
      LibrarySortId<BookKind>(BookFieldIdentities.publisherId);
  static const releaseDate =
      LibrarySortId<BookKind>(BookFieldIdentities.releaseDateId);
  static const pageCount =
      LibrarySortId<BookKind>(BookFieldIdentities.pageCountId);
  static const series = LibrarySortId<BookKind>(BookFieldIdentities.seriesId);
  static const rating = LibrarySortId<BookKind>('book.rating');
  static const pricePaid = LibrarySortId<BookKind>('book.price_paid');
  static const updatedAt = LibrarySortId<BookKind>('book.updated_at');
}

abstract final class BookGroupIds {
  static const author = LibraryGroupId<BookKind, String?>('book.author');
  static const publisher =
      LibraryGroupId<BookKind, String?>(BookFieldIdentities.publisherId);
  static const series =
      LibraryGroupId<BookKind, String?>(BookFieldIdentities.seriesId);
  static const location = LibraryGroupId<BookKind, String?>(
    'book.location',
    semantic: LibraryGroupSemantic.location,
  );
  static const condition = LibraryGroupId<BookKind, String?>('book.condition');
  static const rating = LibraryGroupId<BookKind, int?>('book.rating');
  static const format =
      LibraryGroupId<BookKind, String?>(BookFieldIdentities.formatId);
  static const translator =
      LibraryGroupId<BookKind, String?>('book.translator');
}

abstract final class BookFacetIds {
  static const author = LibraryFacetId<BookKind, String>('book.author');
  static const publisher =
      LibraryFacetId<BookKind, String>(BookFieldIdentities.publisherId);
  static const genre = LibraryFacetId<BookKind, String>('book.genre');
  static const format =
      LibraryFacetId<BookKind, String>(BookFieldIdentities.formatId);
  static const translator = LibraryFacetId<BookKind, String>('book.translator');
  static const subject = LibraryFacetId<BookKind, String>('book.subject');
}
