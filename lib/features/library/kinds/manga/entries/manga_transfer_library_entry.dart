import '../domain/manga_library_entry.dart';

MangaLibraryEntry mangaTransferLibraryEntry(Object value) {
  if (value is MangaLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MangaLibraryEntry');
}
