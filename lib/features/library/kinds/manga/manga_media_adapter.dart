import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';

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
