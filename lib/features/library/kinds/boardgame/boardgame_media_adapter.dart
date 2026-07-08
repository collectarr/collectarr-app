import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_media_adapter_builder.dart';

final boardGamesMediaAdapter = plannedMediaAdapter(
  boardGamesLibraryConfig,
  entryAccessors: boardGameEntryAccessors,
  compareEntriesByColumn: compareBoardGameEntriesByColumn,
);
