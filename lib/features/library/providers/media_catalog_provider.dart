import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String? _cachedMediaCatalogBaseUrl;
List<CatalogMediaType>? _cachedMediaCatalog;

void resetMediaCatalogCacheForTesting() {
  _cachedMediaCatalogBaseUrl = null;
  _cachedMediaCatalog = null;
}

final mediaCatalogProvider =
    FutureProvider<List<CatalogMediaType>>((ref) async {
  final api = ref.watch(apiClientProvider);
  if (_cachedMediaCatalogBaseUrl == api.baseUrl &&
      _cachedMediaCatalog != null) {
    return _cachedMediaCatalog!;
  }
  try {
    final catalog = await api.metadataMediaTypes();
    if (catalog.isNotEmpty) {
      final normalizedCatalog = _normalizeCatalogMediaTypes(catalog);
      _cachedMediaCatalogBaseUrl = api.baseUrl;
      _cachedMediaCatalog = normalizedCatalog;
      return normalizedCatalog;
    }
  } catch (error, stackTrace) {
    logRecoverableError(
      source: 'media_catalog',
      message:
          'Failed to load media catalog from metadata server; using fallback catalog.',
      error: error,
      stackTrace: stackTrace,
    );
  }
  return fallbackMediaCatalog;
});

final videoPhysicalMediaFormatsProvider = Provider<List<PhysicalMediaFormat>>(
  (ref) {
    final catalog = _catalogOrFallback(ref.watch(mediaCatalogProvider));
    final formats = physicalMediaFormatsFromCatalog(catalog);
    return formats.isNotEmpty
        ? formats
        : collectarrKindModulesByKind[CatalogMediaKind.movie]!
            .physicalMediaFormats;
  },
);

List<CatalogMediaType> _catalogOrFallback(
  AsyncValue<List<CatalogMediaType>> value,
) {
  return value.when(
    data: (catalog) => catalog,
    error: (_, __) => fallbackMediaCatalog,
    loading: () => fallbackMediaCatalog,
  );
}

List<PhysicalMediaFormat> physicalMediaFormatsForKind(
  Iterable<CatalogMediaType> catalog,
  CatalogMediaKind kind,
) {
  final mediaFamily = catalogMediaFamilyForKind(kind);
  final formats = physicalMediaFormatsFromCatalog(catalog,
      kind: kind.apiValue, mediaFamily: mediaFamily);
  if (formats.isNotEmpty) {
    return formats;
  }
  return collectarrKindModulesByKind[kind]?.physicalMediaFormats ?? const [];
}

List<CatalogMediaType> _normalizeCatalogMediaTypes(
  List<CatalogMediaType> catalog,
) {
  return [
    for (final type in catalog) normalizeCatalogMediaTypeDefaults(type),
  ];
}

final fallbackMediaCatalog = [
  for (final module in collectarrKindModules)
    CatalogMediaType(
      kind: module.kind.apiValue,
      singularLabel: module.identity.singularLabel,
      pluralLabel: module.identity.pluralLabel,
      routeSegments: module.identity.routeSegments,
      defaultProvider: module.metadata.defaultProviderId,
      providers: [
        for (final provider in module.metadata.providers) provider.id,
      ],
      isTopLevel: module.identity.isTopLevel,
      physicalFormats: [
        for (final format in module.physicalMediaFormats)
          CatalogPhysicalFormat(
            id: format.id,
            label: format.label,
            mediaFamily: format.mediaFamily,
            variantType: format.variantType,
            aliases: format.aliases.toList(growable: false),
          ),
      ],
    ),
];
