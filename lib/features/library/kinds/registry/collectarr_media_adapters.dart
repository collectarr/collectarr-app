import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';

final collectarrMediaAdapters = LibraryMediaAdapterRegistry([
  for (final module in collectarrKindModules) module.mediaAdapter,
]);