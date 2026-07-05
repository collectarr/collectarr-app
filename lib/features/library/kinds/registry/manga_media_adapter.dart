part of 'media_adapters.dart';

final mangaMediaAdapter = plannedMediaAdapter(
  mangaLibraryConfig,
  entryAccessors: plannedBookEntryAccessors,
  compareEntriesByColumn: compareBookEntriesByColumn,
);
