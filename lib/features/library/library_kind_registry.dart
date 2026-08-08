import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';

export 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
export 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';

class LibraryKindRegistry {
  LibraryKindRegistry._();

  static final LibraryKindRegistry instance = LibraryKindRegistry._();

  final Map<CatalogMediaKind, LibraryKindRuntime> _byKind = {};

  void register(LibraryKindRuntime runtime) {
    if (_byKind.containsKey(runtime.kind)) {
      throw StateError(
        'Duplicate LibraryKindSpec registration for kind: ${runtime.kind}',
      );
    }
    validateKindRuntime(runtime);
    _byKind[runtime.kind] = runtime;
  }

  void registerAll(Iterable<LibraryKindRuntime> runtimes) {
    for (final r in runtimes) {
      register(r);
    }
  }

  LibraryKindRuntime getByKind(CatalogMediaKind kind) {
    if (_byKind.isEmpty) {
      registerAll(collectarrKindModules);
    }
    final runtime = _byKind[kind];
    if (runtime == null) {
      throw ArgumentError('No LibraryKindRuntime registered for kind: $kind');
    }
    return runtime;
  }

  LibraryKindRuntime getByType(LibraryTypeConfig type) {
    return getByKind(type.workspace.kind);
  }

  List<LibraryKindRuntime> get allRuntimes {
    if (_byKind.isEmpty) {
      registerAll(collectarrKindModules);
    }
    return List.unmodifiable(_byKind.values);
  }

  void resetForTesting() {
    _byKind.clear();
  }
}

LibraryKindRuntime libraryKindRuntimeForKind(CatalogMediaKind kind) {
  return LibraryKindRegistry.instance.getByKind(kind);
}

LibraryKindRuntime libraryKindRuntimeForType(LibraryTypeConfig type) {
  return LibraryKindRegistry.instance.getByType(type);
}

LibraryKindRuntime libraryKindModuleForKind(CatalogMediaKind kind) {
  return libraryKindRuntimeForKind(kind);
}

LibraryKindRuntime libraryKindModuleForType(LibraryTypeConfig type) {
  return libraryKindRuntimeForType(type);
}

LibraryKindProviderMapper libraryKindProviderMapperForType(LibraryTypeConfig type) {
  return libraryKindRuntimeForType(type).providerMapper;
}

LibraryFacetProvider libraryFacetProviderForType(LibraryTypeConfig type) {
  return LibraryFacetModuleProvider(libraryKindRuntimeForType(type).facets);
}
