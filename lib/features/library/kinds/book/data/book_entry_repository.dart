import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/entries/typed_library_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';

/// Kind projection of the complete, independently editable local entry.
final class BookEntryRepository extends TypedLibraryEntryRepository<BookLibraryEntry> {
  const BookEntryRepository(super.database);
  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;
  @override
  BookLibraryEntry decode(Map<String, dynamic> json) => BookLibraryEntry.fromJson(json);
  @override
  Map<String, dynamic> encode(BookLibraryEntry item) => item.toJson();
  @override
  BookLibraryEntry deleted(BookLibraryEntry item, DateTime at) => item.copyWith(deletedAt: at, updatedAt: at);
}
