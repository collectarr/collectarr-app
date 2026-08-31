import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';

final collectarrLibraryTypes = LibraryTypeRegistry([
  for (final module in collectarrKindModules) module.type,
]);
