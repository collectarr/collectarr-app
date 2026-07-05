part of 'media_adapters.dart';

final musicMediaAdapter = plannedMediaAdapter(
  musicLibraryConfig,
  entryAccessors: plannedMusicEntryAccessors,
  compareEntriesByColumn: compareMusicEntriesByColumn,
);
