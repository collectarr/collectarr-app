import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';

final tvMediaAdapter = plannedMediaAdapter(
  tvLibraryConfig,
  entryAccessors: defaultEntryAccessors,
  compareEntriesByColumn: (left, right, column) =>
      comparePlannedMediaEntriesByColumn(
        left,
        right,
        column,
        defaultEntryAccessors,
      ),
);
