part of 'planned_media_adapters.dart';

final gamesMediaAdapter = plannedMediaAdapter(
  gamesLibraryConfig,
  entryAccessors: plannedGameEntryAccessors,
  compareEntriesByColumn: compareGameEntriesByColumn,
);
