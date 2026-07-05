part of 'media_adapters.dart';

final booksMediaAdapter = plannedMediaAdapter(
  booksLibraryConfig,
  entryAccessors: bookEntryAccessors,
  compareEntriesByColumn: compareBookEntriesByColumn,
);
