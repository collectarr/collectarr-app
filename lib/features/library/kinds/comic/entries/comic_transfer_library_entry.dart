import '../domain/comic_library_entry.dart';

ComicLibraryEntry comicTransferLibraryEntry(Object value) {
  if (value is ComicLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected ComicLibraryEntry');
}
