import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/library_catalog_resolution.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

List<CatalogMediaType> orderedLibraryHomeTypes(
  List<CatalogMediaType> catalog,
  LibraryNavPreferences preferences,
) {
  final topLevelByKind = {
    for (final type in catalog)
      if (type.isTopLevel) type.kind: type,
  };
  final defaultKinds = [
    for (final config in collectarrLibraryTypes.types) config.workspace.kind,
  ];
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
  final normalizedType = normalizeCatalogMediaTypeDefaults(type);
  const presentation = genericLibraryMediaPresentation;
  return LibraryTypeConfig(
    workspace: LibraryWorkspaceConfig(
      kind: normalizedType.kind,
      title: catalogDisplayLabel(
        normalizedType.pluralLabel,
        normalizedType.kind,
        plural: true,
      ),
      icon: libraryIconForKind(normalizedType.kind),
      preferencePrefix: 'catalog_${normalizedType.kind}',
      defaultSortColumn: LibrarySortColumn.title,
      defaultVisibleColumns: presentation.defaultVisibleColumns,
    ),
    singularLabel: catalogDisplayLabel(
      normalizedType.singularLabel,
      normalizedType.kind,
    ),
    pluralLabel: catalogDisplayLabel(
      normalizedType.pluralLabel,
      normalizedType.kind,
      plural: true,
    ),
    defaultMetadataProvider: normalizedType.defaultProvider ??
        (normalizedType.providers.isEmpty ? '' : normalizedType.providers.first),
    metadataProviders: const [],
    trackingProfile: catalogTrackingProfileForKind(normalizedType.kind),
    presentation: presentation,
  ).resolveWithCatalog([normalizedType]);
}
