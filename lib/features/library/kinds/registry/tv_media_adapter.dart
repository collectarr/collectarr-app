part of 'media_adapters.dart';

final tvMediaAdapter = plannedMediaAdapter(
  tvLibraryConfig,
  entryAccessors: movieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
