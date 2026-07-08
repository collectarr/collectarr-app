part of 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final moviesMediaAdapter = plannedMediaAdapter(
  moviesLibraryConfig,
  entryAccessors: movieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
