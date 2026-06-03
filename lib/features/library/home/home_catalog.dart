import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/runtime/runtime_catalog_library_type_builder.dart';

List<CatalogMediaType> orderedLibraryHomeTypes(
  List<CatalogMediaType> catalog,
  LibraryNavPreferences preferences,
) {
  final byKind = {
    for (final type in catalog) type.kind: type,
  };
  final topLevelByKind = {
    for (final type in catalog)
      if (type.isTopLevel || collectarrLibraryTypes.byKind(type.kind) != null)
        type.kind: type,
  };
  final defaultKinds = [
    for (final config in collectarrLibraryTypes.types)
      config.workspace.kind.apiValue,
  ];
  for (final kind in defaultKinds) {
    topLevelByKind.putIfAbsent(kind, () {
      final fromCatalog = byKind[kind];
      if (fromCatalog != null) {
        return fromCatalog;
      }
      return _fallbackTypeForKind(kind);
    });
  }
  final orderedKinds = preferences.orderedKinds([
    ...defaultKinds,
    ...topLevelByKind.keys,
  ]);
  final ordered = <CatalogMediaType>[];
  for (final kind in orderedKinds) {
    final type = topLevelByKind.remove(kind);
    if (type != null) {
      ordered.add(type);
    }
  }
  ordered.addAll(topLevelByKind.values.toList()
    ..sort((a, b) => a.pluralLabel.compareTo(b.pluralLabel)));
  return ordered.isEmpty
      ? fallbackMediaCatalog.where((type) => type.isTopLevel).toList()
      : ordered;
}

CatalogMediaType _fallbackTypeForKind(String kind) {
  for (final type in fallbackMediaCatalog) {
    if (type.kind == kind) {
      return type;
    }
  }
  // Safety fallback for unexpected kinds that are known by registry but absent
  // from fallbackMediaCatalog.
  final title = catalogTitleFromToken(kind, emptyLabel: 'Library');
  return CatalogMediaType(
    kind: kind,
    singularLabel: title,
    pluralLabel: title.endsWith('s') ? title : '${title}s',
    routeSegments: [kind],
    isTopLevel: true,
  );
}

List<CatalogMediaType> visibleLibraryHomeTypes(
  List<CatalogMediaType> types,
  LibraryNavPreferences preferences,
) {
  final visible = [
    for (final type in types)
      if (preferences.isVisible(type.kind)) type,
  ];
  return visible.isEmpty ? types.take(1).toList(growable: false) : visible;
}

CatalogMediaType selectedLibraryHomeType(
  List<CatalogMediaType> types,
  String kind,
) {
  for (final type in types) {
    if (type.kind == kind) {
      return type;
    }
  }
  return types.first;
}

LibraryTypeConfig libraryConfigForCatalogType(
  CatalogMediaType type,
  LibraryTypeRegistry registry,
) {
  final known = registry.byKind(type.kind);
  if (known != null) {
    return known;
  }
  return buildRuntimeCatalogLibraryTypeConfig(type);
}
