part of 'planned_media_adapters.dart';

final mangaMediaAdapter = plannedMediaAdapter(
  mangaLibraryConfig,
  entryAccessors: plannedBookEntryAccessors,
  compareEntriesByColumn: compareBookEntriesByColumn,
);
