part of 'media_adapters.dart';

final boardGamesMediaAdapter = plannedMediaAdapter(
  boardGamesLibraryConfig,
  entryAccessors: boardGameEntryAccessors,
  compareEntriesByColumn: compareBoardGameEntriesByColumn,
);
