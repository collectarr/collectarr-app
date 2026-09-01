import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_metadata_provider_models.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

LibraryKindRuntime buildRuntimeCatalogLibraryRuntime(CatalogMediaType type) {
  final normalizedType = normalizeCatalogMediaTypeDefaults(type);
  final mediaKind = catalogMediaKindFromApiValue(normalizedType.kind);
  final base = libraryKindRuntimeForKind(mediaKind);
  final singularLabel = _runtimeCatalogDisplayLabel(
    normalizedType.singularLabel,
    normalizedType.kind,
  );
  final pluralLabel = _runtimeCatalogDisplayLabel(
    normalizedType.pluralLabel,
    normalizedType.kind,
    plural: true,
  );
  final resolvedProviders = _resolveRuntimeMetadataProviders(
    normalizedType,
    fallback: base.metadata.providers,
  );
  final identity = LibraryKindIdentity(
    kind: mediaKind,
    singularLabel: singularLabel,
    pluralLabel: pluralLabel,
    title: pluralLabel,
    icon: base.identity.icon,
    accent: base.identity.accent,
    preferencePrefix: 'catalog_${normalizedType.kind}',
    defaultDensityPreset: base.identity.defaultDensityPreset,
    availableDensityPresets: base.identity.availableDensityPresets,
    toolbarActions: base.identity.toolbarActions,
  );
  final metadata = LibraryMetadataCapability(
    defaultProviderId: normalizedType.defaultProvider ??
        (resolvedProviders.isEmpty
            ? base.metadata.defaultProviderId
            : resolvedProviders.first.id),
    providers:
        resolvedProviders.isEmpty ? base.metadata.providers : resolvedProviders,
    supportsServerCompare: base.metadata.supportsServerCompare,
  );
  return base.withCatalogMetadata(identity: identity, metadata: metadata);
}

List<LibraryMetadataProviderOption> _resolveRuntimeMetadataProviders(
  CatalogMediaType type, {
  required List<LibraryMetadataProviderOption> fallback,
}) {
  return [
    for (final providerId in type.providers)
      _resolveRuntimeMetadataProvider(type.kind, providerId,
          fallback: fallback),
  ];
}

LibraryMetadataProviderOption _resolveRuntimeMetadataProvider(
  String kind,
  String providerId, {
  required List<LibraryMetadataProviderOption> fallback,
}) {
  final normalizedProviderId = providerId.trim();
  final fallbackOption =
      fallback.cast<LibraryMetadataProviderOption?>().firstWhere(
            (option) => option?.id == normalizedProviderId,
            orElse: () => null,
          );
  final option = fallbackOption ??
      collectarrMetadataProviderRegistry.byId(normalizedProviderId);
  if (option == null) {
    return LibraryMetadataProviderOption(
      id: normalizedProviderId,
      label: catalogTitleFromToken(normalizedProviderId),
      supportedKinds: {kind},
    );
  }
  if (option.supportedKinds.contains(kind)) {
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

String _runtimeCatalogDisplayLabel(
  String value,
  String rawKind, {
  bool plural = false,
}) {
  final trimmed = value.trim();
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  final label = catalogTitleFromToken(rawKind, emptyLabel: 'Library');
  return plural ? '${label}s' : label;
}
