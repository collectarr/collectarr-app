part of 'media_adapters.dart';

final animeMediaAdapter = plannedMediaAdapter(
  animeLibraryConfig,
  entryAccessors: plannedMovieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
