import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_media_adapter_builder.dart';

final musicMediaAdapter = plannedMediaAdapter(
  musicLibraryConfig,
  entryAccessors: musicEntryAccessors,
  compareEntriesByColumn: compareMusicEntriesByColumn,
);
