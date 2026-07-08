part of 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final boardGamesMediaAdapter = plannedMediaAdapter(
  boardGamesLibraryConfig,
  entryAccessors: boardGameEntryAccessors,
  compareEntriesByColumn: compareBoardGameEntriesByColumn,
);
