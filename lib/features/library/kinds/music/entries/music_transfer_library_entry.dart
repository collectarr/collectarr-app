import '../domain/music_library_entry.dart';

MusicLibraryEntry musicTransferLibraryEntry(Object value) {
  if (value is MusicLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected MusicLibraryEntry');
}
