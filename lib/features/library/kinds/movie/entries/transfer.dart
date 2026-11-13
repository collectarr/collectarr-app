import '../domain/movie_library_entry.dart';

MovieLibraryEntry movieTransferLibraryEntry(Object value) {
  if (value is MovieLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MovieLibraryEntry');
}
