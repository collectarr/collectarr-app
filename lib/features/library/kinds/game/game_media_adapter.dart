import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_media_adapter_builder.dart';

final gamesMediaAdapter = plannedMediaAdapter(
  gamesLibraryConfig,
  entryAccessors: gameEntryAccessors,
  compareEntriesByColumn: compareGameEntriesByColumn,
);
