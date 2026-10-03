import '../domain/tv_library_entry.dart';

TvLibraryEntry tvTransferLibraryEntry(Object value) {
  if (value is TvLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected TvLibraryEntry');
}
