part of 'media_adapters.dart';

final tvMediaAdapter = plannedMediaAdapter(
  tvLibraryConfig,
  entryAccessors: plannedMovieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
