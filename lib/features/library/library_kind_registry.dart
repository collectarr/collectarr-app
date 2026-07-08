import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

export 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
export 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';

LibraryKindModule libraryKindModuleForType(LibraryTypeConfig type) {
  return collectarrKindModules.firstWhere(
    (module) => module.type.workspace.kind.apiValue == type.workspace.kind.apiValue,
  );
}

LibraryKindProviderMapper libraryKindProviderMapperForType(LibraryTypeConfig type) {
  return libraryKindModuleForType(type).providerMapper;
}
