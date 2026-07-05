part of 'media_adapters.dart';

final moviesMediaAdapter = plannedMediaAdapter(
  moviesLibraryConfig,
  entryAccessors: plannedMovieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
