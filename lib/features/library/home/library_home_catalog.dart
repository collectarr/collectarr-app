import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
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
  final providers = _providerOptionsForCatalogType(type);
  const presentation = genericLibraryMediaPresentation;
  return LibraryTypeConfig(
    workspace: LibraryWorkspaceConfig(
      kind: type.kind,
      title: _displayLabel(type.pluralLabel, type.kind, plural: true),
      icon: libraryIconForKind(type.kind),
      preferencePrefix: 'catalog_${type.kind}',
      defaultSortColumn: LibrarySortColumn.title,
      defaultVisibleColumns: presentation.defaultVisibleColumns,
    ),
    singularLabel: _displayLabel(type.singularLabel, type.kind),
    pluralLabel: _displayLabel(type.pluralLabel, type.kind, plural: true),
    defaultMetadataProvider: type.defaultProvider ??
        (type.providers.isEmpty ? '' : type.providers.first),
    metadataProviders: providers,
    trackingProfile: _trackingProfileForKind(type.kind),
    presentation: presentation,
  );
}

List<LibraryMetadataProviderOption> _providerOptionsForCatalogType(
  CatalogMediaType type,
) {
  final kind = type.kind.trim().toLowerCase();
  return [
    for (final providerId in type.providers)
      _providerOptionForCatalogKind(providerId, kind),
  ];
}

LibraryMetadataProviderOption _providerOptionForCatalogKind(
  String providerId,
  String kind,
) {
  final option = collectarrMetadataProviderRegistry.byId(providerId);
  if (option == null) {
    return LibraryMetadataProviderOption(
      id: providerId,
      label: _titleFromToken(providerId),
      supportedKinds: {kind},
    );
  }
  if (option.supportsKind(kind)) {
    return option;
  }
  return LibraryMetadataProviderOption(
    id: option.id,
    label: option.label,
    description: option.description,
    supportedKinds: {...option.supportedKinds, kind},
    requiresApiKey: option.requiresApiKey,
    usagePolicy: option.usagePolicy,
  );
}

MediaTrackingProfile _trackingProfileForKind(String kind) {
  return switch (kind) {
    'anime' || 'movie' || 'tv' => videoTrackingProfile,
    'boardgame' || 'game' => gameTrackingProfile,
    'comic' => comicTrackingProfile,
    'music' => listeningTrackingProfile,
    _ => readingTrackingProfile,
  };
}

String _displayLabel(String value, String fallback, {bool plural = false}) {
  final trimmed = value.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  final label = _titleFromToken(fallback);
  return plural ? '${label}s' : label;
}

String _titleFromToken(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'[_-]+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'Library';
  }
  return [
    for (final part in parts)
      if (part.length == 1)
        part.toUpperCase()
      else
        '${part[0].toUpperCase()}${part.substring(1)}',
  ].join(' ');
}
