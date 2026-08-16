import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
export 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
export 'package:collectarr_app/features/library/kinds/registry/collectarr_media_adapters.dart';

final class LibraryKindRegistry {
  LibraryKindRegistry(
    Iterable<LibraryKindRuntime> specs,
  ) : _byKind = _buildValidatedRegistry(specs);

  final Map<CatalogMediaKind, LibraryKindRuntime> _byKind;

  static Map<CatalogMediaKind, LibraryKindRuntime> _buildValidatedRegistry(
    Iterable<LibraryKindRuntime> specs,
  ) {
    final map = <CatalogMediaKind, LibraryKindRuntime>{};
    for (final spec in specs) {
      if (map.containsKey(spec.kind)) {
        throw StateError(
          'Duplicate LibraryKindSpec registration for kind: ${spec.kind}',
        );
      }
      validateKindRuntime(spec);
      map[spec.kind] = spec;
    }
    return Map.unmodifiable(map);
  }

  LibraryKindRuntime require(CatalogMediaKind kind) {
    final runtime = _byKind[kind];
    if (runtime == null) {
      throw ArgumentError('No LibraryKindRuntime registered for kind: $kind');
    }
    return runtime;
  }

  LibraryKindRuntime? tryGet(CatalogMediaKind kind) => _byKind[kind];

  LibraryKindRuntime requireForType(LibraryTypeConfig type) =>
      require(type.workspace.kind);

  LibraryKindRuntime? tryGetForType(LibraryTypeConfig type) =>
      tryGet(type.workspace.kind);

  LibraryKindRuntime getByKind(CatalogMediaKind kind) => require(kind);

  LibraryKindRuntime getByType(LibraryTypeConfig type) => requireForType(type);

  List<LibraryKindRuntime> get allRuntimes => List.unmodifiable(_byKind.values);
}

final defaultLibraryKindRegistry = LibraryKindRegistry(collectarrKindModules);

final libraryKindRegistryProvider = Provider<LibraryKindRegistry>(
  (ref) => defaultLibraryKindRegistry,
);

LibraryKindRuntime libraryKindRuntimeForKind(
  CatalogMediaKind kind, {
  LibraryKindRegistry? registry,
}) {
  return (registry ?? defaultLibraryKindRegistry).require(kind);
}

LibraryKindRuntime libraryKindRuntimeForType(
  LibraryTypeConfig type, {
  LibraryKindRegistry? registry,
}) {
  return (registry ?? defaultLibraryKindRegistry).requireForType(type);
}

LibraryKindProviderMapper? libraryKindProviderMapperForType(
  LibraryTypeConfig type, {
  LibraryKindRegistry? registry,
}) {
  return libraryKindRuntimeForType(type, registry: registry).providerMapper;
}
