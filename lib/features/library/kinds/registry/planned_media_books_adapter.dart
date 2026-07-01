part of 'planned_media_adapters.dart';

final booksMediaAdapter = plannedMediaAdapter(
  booksLibraryConfig,
  entryAccessors: plannedBookEntryAccessors,
  compareEntriesByColumn: compareBookEntriesByColumn,
);
