import '../domain/game_library_entry.dart';

GameLibraryEntry gameTransferLibraryEntry(Object value) {
  if (value is GameLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected GameLibraryEntry');
}
