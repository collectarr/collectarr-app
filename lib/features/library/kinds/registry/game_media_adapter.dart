part of 'media_adapters.dart';

final gamesMediaAdapter = plannedMediaAdapter(
  gamesLibraryConfig,
  entryAccessors: gameEntryAccessors,
  compareEntriesByColumn: compareGameEntriesByColumn,
);
