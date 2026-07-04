import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace_view.dart';
import 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';
export 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';

final collectarrMediaAdapters = LibraryMediaAdapterRegistry([
  comicsMediaAdapter,
  ...plannedMediaAdapters.adapters,
]);