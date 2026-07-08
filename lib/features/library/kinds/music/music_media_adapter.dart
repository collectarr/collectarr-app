part of 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final musicMediaAdapter = plannedMediaAdapter(
  musicLibraryConfig,
  entryAccessors: musicEntryAccessors,
  compareEntriesByColumn: compareMusicEntriesByColumn,
);
