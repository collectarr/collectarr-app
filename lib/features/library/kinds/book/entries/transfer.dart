import '../domain/book_library_entry.dart';

BookLibraryEntry bookTransferLibraryEntry(Object value) {
  if (value is BookLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected BookLibraryEntry');
}
