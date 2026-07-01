part of 'planned_media_adapters.dart';

final moviesMediaAdapter = plannedMediaAdapter(
  moviesLibraryConfig,
  entryAccessors: plannedMovieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
