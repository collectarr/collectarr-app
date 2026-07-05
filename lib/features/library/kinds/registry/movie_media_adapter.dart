part of 'media_adapters.dart';

final moviesMediaAdapter = plannedMediaAdapter(
  moviesLibraryConfig,
  entryAccessors: movieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
