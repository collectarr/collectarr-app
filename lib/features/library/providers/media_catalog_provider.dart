import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/v1/catalog_item_v1_kind_identities.dart';
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

List<PhysicalMediaFormat> physicalMediaFormatsForKind(
  Iterable<CatalogMediaType> catalog,
  CatalogMediaKind kind,
) {
  if (kind.isUnknown) return const [];
  final mediaFamily = catalogMediaFamilyForKind(kind);
  if (mediaFamily == null) {
    throw StateError('No media family registered for ${kind.apiValue}.');
  }
  final formats = physicalMediaFormatsFromCatalog(catalog,
      kind: kind, mediaFamily: mediaFamily);
  if (formats.isNotEmpty) {
    return formats;
  }
  return const [];
}

List<CatalogMediaType> _normalizeCatalogMediaTypes(
  List<CatalogMediaType> catalog,
) {
  return [
    for (final type in catalog) normalizeCatalogMediaTypeDefaults(type),
  ];
}

final fallbackMediaCatalog = [
  for (final entry in catalogItemV1KindIdentities.entries)
    CatalogMediaType(
      kind: entry.key.apiValue,
      singularLabel: entry.value.singularLabel,
      pluralLabel: entry.value.pluralLabel,
      routeSegments: entry.value.routeSegments,
      isTopLevel: entry.value.isTopLevel,
    ),
];
