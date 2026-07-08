part of 'package:collectarr_app/features/library/kinds/registry/media_adapters.dart';

final gamesMediaAdapter = plannedMediaAdapter(
  gamesLibraryConfig,
  entryAccessors: gameEntryAccessors,
  compareEntriesByColumn: compareGameEntriesByColumn,
);
