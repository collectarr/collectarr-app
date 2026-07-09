import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_providers.dart';

extension LibraryTypeConfigCatalogResolution on LibraryTypeConfig {
  LibraryTypeConfig resolveWithCatalog(
    Iterable<CatalogMediaType> catalog, {
    LibraryMetadataProviderRegistry providerRegistry =
        collectarrMetadataProviderRegistry,
  }) {
    final rawMediaType = _mediaTypeForKind(catalog, workspace.kind);
    if (rawMediaType == null) {
      return this;
    }
    final mediaType = normalizeCatalogMediaTypeDefaults(rawMediaType);
    final resolvedProviders = _resolveProviderOptions(
      mediaType.providers,
      kind: mediaType.kind,
      fallback: metadataProviders,
      registry: providerRegistry,
    );
    return LibraryTypeConfig(
      workspace: workspace,
      defaultSortColumn: defaultSortColumn,
      defaultVisibleColumns: defaultVisibleColumns,
      availableSortColumns: availableSortColumns,
      availableSortColumnDefinitions: availableSortColumnDefinitions,
      availableTableColumns: availableTableColumns,
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
      editPresentation: editPresentation,
      addChrome: addChrome,
      editChrome: editChrome,
      mediaFields: mediaFields,
      releaseFields: releaseFields,
      collectionExportTitleLabel: collectionExportTitleLabel,
      manualAddUsesTitleAsSeries: manualAddUsesTitleAsSeries,
      editUsesTitleAsSeries: editUsesTitleAsSeries,
      transferableFieldKeys: transferableFieldKeys,
      addDialogLauncher: addDialogLauncher,
      editDialogBuilder: editDialogBuilder,
      mediaEditDialogBuilder: mediaEditDialogBuilder,
      releaseEditDialogBuilder: releaseEditDialogBuilder,
      detailPageBuilder: detailPageBuilder,
      inspectorHeroBuilder: inspectorHeroBuilder,
      inspectorSectionsBuilder: inspectorSectionsBuilder,
      showsDefaultInspectorPersonalSection:
          showsDefaultInspectorPersonalSection,
      workspaceBehavior: workspaceBehavior,
    );
  }
}

extension LibraryTypeRegistryCatalogResolution on LibraryTypeRegistry {
  LibraryTypeRegistry resolveWithCatalog(
    Iterable<CatalogMediaType> catalog, {
    LibraryMetadataProviderRegistry providerRegistry =
        collectarrMetadataProviderRegistry,
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
  required LibraryMetadataProviderRegistry registry,
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
  required LibraryMetadataProviderRegistry registry,
}) {
  final option = fallback ?? registry.byId(providerId);
  if (option == null) {
    return LibraryMetadataProviderOption(
      id: providerId,
      label: catalogTitleFromToken(providerId),
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
