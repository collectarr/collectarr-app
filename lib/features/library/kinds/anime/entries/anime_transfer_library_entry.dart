import '../domain/anime_library_entry.dart';

AnimeLibraryEntry animeTransferLibraryEntry(Object value) {
  if (value is AnimeLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected AnimeLibraryEntry');
}
