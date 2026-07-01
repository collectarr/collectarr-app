part of 'planned_media_adapters.dart';

final animeMediaAdapter = plannedMediaAdapter(
  animeLibraryConfig,
  entryAccessors: plannedMovieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
