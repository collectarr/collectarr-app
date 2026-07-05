part of 'media_adapters.dart';

final musicMediaAdapter = plannedMediaAdapter(
  musicLibraryConfig,
  entryAccessors: musicEntryAccessors,
  compareEntriesByColumn: compareMusicEntriesByColumn,
);
