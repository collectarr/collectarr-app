part of 'media_adapters.dart';

final boardGamesMediaAdapter = plannedMediaAdapter(
  boardGamesLibraryConfig,
  entryAccessors: plannedBoardGameEntryAccessors,
  compareEntriesByColumn: compareBoardGameEntriesByColumn,
);
