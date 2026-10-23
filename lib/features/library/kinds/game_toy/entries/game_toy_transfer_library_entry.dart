import '../domain/game_toy_library_entry.dart';

GameToyLibraryEntry gameToyTransferLibraryEntry(Object value) {
  if (value is GameToyLibraryEntry) return value;
  throw ArgumentError.value(value, 'updated', 'Expected GameToyLibraryEntry');
}
