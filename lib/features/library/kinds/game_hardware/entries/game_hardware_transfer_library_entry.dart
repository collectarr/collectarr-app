import '../domain/game_hardware_library_entry.dart';

GameHardwareLibraryEntry gameHardwareTransferLibraryEntry(Object value) {
  if (value is GameHardwareLibraryEntry) return value;
  throw ArgumentError.value(
      value, 'updated', 'Expected GameHardwareLibraryEntry');
}
