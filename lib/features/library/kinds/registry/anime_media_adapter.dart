part of 'media_adapters.dart';

final animeMediaAdapter = plannedMediaAdapter(
  animeLibraryConfig,
  entryAccessors: movieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
