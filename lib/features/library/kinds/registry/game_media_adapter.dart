part of 'media_adapters.dart';

final gamesMediaAdapter = plannedMediaAdapter(
  gamesLibraryConfig,
  entryAccessors: plannedGameEntryAccessors,
  compareEntriesByColumn: compareGameEntriesByColumn,
);
