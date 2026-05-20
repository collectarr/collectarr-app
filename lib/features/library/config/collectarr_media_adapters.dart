import 'package:collectarr_app/features/comics/workspace/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/planned_media_adapters.dart';

final collectarrMediaAdapters = LibraryMediaAdapterRegistry([
  comicsMediaAdapter,
  ...plannedMediaAdapters.adapters,
]);
