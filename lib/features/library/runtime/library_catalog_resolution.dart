import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_metadata_provider_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_registry.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';

extension LibraryKindRegistryCatalogResolution on LibraryKindRegistry {
  LibraryKindRegistry resolveWithCatalog(
    Iterable<CatalogMediaType> catalog, {
    ProviderConnectorRegistry? providerRegistry,
  }) {
    return LibraryKindRegistry([
      for (final type in allRuntimes)
        type.resolveWithCatalog(catalog, providerRegistry: providerRegistry),
    ]);
  }
}

extension LibraryKindRuntimeCatalogResolution on LibraryKindRuntime {
  LibraryKindRuntime resolveWithCatalog(
    Iterable<CatalogMediaType> catalog, {
    ProviderConnectorRegistry? providerRegistry,
  }) {
    final rawMediaType = _mediaTypeForKind(catalog, kind);
    if (rawMediaType == null) {
      return this;
    }
    final effectiveRegistry =
        providerRegistry ?? defaultProviderConnectorRegistry;
    final mediaType = normalizeCatalogMediaTypeDefaults(rawMediaType);
    final resolvedProviders = _resolveProviderOptions(
      mediaType.providers,
      kind: mediaType.kind,
      fallback: metadata.providers,
      registry: effectiveRegistry,
    );
    final resolvedIdentity = LibraryKindIdentity(
      kind: identity.kind,
      singularLabel: mediaType.singularLabel.isEmpty
          ? identity.singularLabel
          : mediaType.singularLabel,
      pluralLabel: mediaType.pluralLabel.isEmpty
          ? identity.pluralLabel
          : mediaType.pluralLabel,
      title: identity.title,
      icon: identity.icon,
      accent: identity.accent,
      preferencePrefix: identity.preferencePrefix,
      defaultDensityPreset: identity.defaultDensityPreset,
      availableDensityPresets: identity.availableDensityPresets,
      toolbarActions: identity.toolbarActions,
    );
    final resolvedMetadata = LibraryMetadataCapability(
      defaultProviderId:
          mediaType.defaultProvider ?? metadata.defaultProviderId,
      providers:
          resolvedProviders.isEmpty ? metadata.providers : resolvedProviders,
      supportsServerCompare: metadata.supportsServerCompare,
    );
    return withCatalogMetadata(
      identity: resolvedIdentity,
      metadata: resolvedMetadata,
    );
  }
}

CatalogMediaType? _mediaTypeForKind(
  Iterable<CatalogMediaType> catalog,
  Object? kind,
) {
  final normalized = catalogMediaKindFromValue(kind).apiValue;
  for (final mediaType in catalog) {
    if (mediaType.kind == normalized) {
      return mediaType;
    }
  }
  return null;
}

List<LibraryMetadataProviderOption> _resolveProviderOptions(
  Iterable<String> providerIds, {
  required String kind,
  required List<LibraryMetadataProviderOption> fallback,
  required ProviderConnectorRegistry registry,
}) {
  final normalizedKind = kind.trim().toLowerCase();
  final fallbackById = {
    for (final provider in fallback) provider.id: provider,
  };
  return [
    for (final providerId in providerIds)
      _providerOptionForId(
        providerId,
        kind: normalizedKind,
        fallback: fallbackById[providerId],
        registry: registry,
      ),
  ];
}

LibraryMetadataProviderOption _providerOptionForId(
  String providerId, {
  required String kind,
  required LibraryMetadataProviderOption? fallback,
  required ProviderConnectorRegistry registry,
}) {
  final connector = registry.get(providerId);
  final option = fallback ??
      (connector != null
          ? LibraryMetadataProviderOption.fromConnector(connector)
          : null);
  if (option == null) {
    return LibraryMetadataProviderOption(
      id: providerId,
      label: catalogTitleFromToken(providerId),
      supportedKinds: {kind},
    );
  }
  if (option.supportsKind(catalogMediaKindFromValue(kind))) {
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
