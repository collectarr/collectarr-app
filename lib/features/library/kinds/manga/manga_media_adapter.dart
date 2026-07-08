part of 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final mangaMediaAdapter = plannedMediaAdapter(
  mangaLibraryConfig,
  entryAccessors: defaultEntryAccessors,
  compareEntriesByColumn: (left, right, column) =>
      comparePlannedMediaEntriesByColumn(
        left,
        right,
        column,
        defaultEntryAccessors,
      ),
);
