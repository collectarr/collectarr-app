import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_registry.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';

extension LibraryTypeConfigCatalogResolution on LibraryTypeConfig {
  LibraryTypeConfig resolveWithCatalog(
    Iterable<CatalogMediaType> catalog, {
    ProviderConnectorRegistry? providerRegistry,
  }) {
    final rawMediaType = _mediaTypeForKind(catalog, workspace.kind);
    if (rawMediaType == null) {
      return this;
    }
    final effectiveRegistry =
        providerRegistry ?? defaultProviderConnectorRegistry;
    final mediaType = normalizeCatalogMediaTypeDefaults(rawMediaType);
    final resolvedProviders = _resolveProviderOptions(
      mediaType.providers,
      kind: mediaType.kind,
      fallback: metadataProviders,
      registry: effectiveRegistry,
    );
    return LibraryTypeConfig(
      workspace: workspace,
      singularLabel: mediaType.singularLabel.isEmpty
          ? singularLabel
          : mediaType.singularLabel,
      pluralLabel:
          mediaType.pluralLabel.isEmpty ? pluralLabel : mediaType.pluralLabel,
      defaultMetadataProvider:
          mediaType.defaultProvider ?? defaultMetadataProvider,
      metadataProviders:
          resolvedProviders.isEmpty ? metadataProviders : resolvedProviders,
      trackingProfile: trackingProfile,
      conditions: conditions,
      grades: grades,
      defaultCondition: defaultCondition,
      defaultGrade: defaultGrade,
      capabilities: capabilities,
      presentation: presentation,
      addChrome: addChrome,
      editChrome: editChrome,
      addDialogLauncher: addDialogLauncher,
      editDialogBuilder: editDialogBuilder,
      mediaEditDialogBuilder: mediaEditDialogBuilder,
      releaseEditDialogBuilder: releaseEditDialogBuilder,
      detailPageBuilder: detailPageBuilder,
      inspectorHeroBuilder: inspectorHeroBuilder,
      inspectorSectionsBuilder: inspectorSectionsBuilder,
      showsDefaultInspectorPersonalSection:
          showsDefaultInspectorPersonalSection,
    );
  }
}

extension LibraryTypeRegistryCatalogResolution on LibraryTypeRegistry {
  LibraryTypeRegistry resolveWithCatalog(
    Iterable<CatalogMediaType> catalog, {
    ProviderConnectorRegistry? providerRegistry,
  }) {
    return LibraryTypeRegistry([
      for (final type in types)
        type.resolveWithCatalog(catalog, providerRegistry: providerRegistry),
    ]);
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
