import '../domain/boardgame_library_entry.dart';

BoardGameLibraryEntry boardGameTransferLibraryEntry(Object value) {
  if (value is BoardGameLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected BoardGameLibraryEntry');
}
