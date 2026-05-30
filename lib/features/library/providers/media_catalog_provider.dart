import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/runtime/library_catalog_resolution.dart';
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
      message: 'Failed to load media catalog from metadata server; using fallback catalog.',
      error: error,
      stackTrace: stackTrace,
    );
  }
  return fallbackMediaCatalog;
});

final resolvedLibraryTypesProvider = Provider<LibraryTypeRegistry>((ref) {
  // Ensure per-kind add builders are registered before resolving types.
  // This is intentionally done here (rather than a top-level module call)
  // so tests that interact with providers also initialize the registry.
  registerLibraryAddBuilders();

  final catalog = _catalogOrFallback(ref.watch(mediaCatalogProvider));
  return collectarrLibraryTypes.resolveWithCatalog(catalog);
});

final resolvedLibraryTypeProvider =
    Provider.family<LibraryTypeConfig, LibraryTypeConfig>((ref, type) {
  final catalog = _catalogOrFallback(ref.watch(mediaCatalogProvider));
  return type.resolveWithCatalog(catalog);
});

final videoPhysicalMediaFormatsProvider = Provider<List<PhysicalMediaFormat>>(
  (ref) {
    final catalog = _catalogOrFallback(ref.watch(mediaCatalogProvider));
    final formats = physicalMediaFormatsFromCatalog(catalog);
    return formats.isEmpty ? videoPhysicalMediaFormats : formats;
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
  Object? kind,
) {
  final normalizedKind = catalogMediaKindFromValue(kind).apiValue;
  final mediaFamily = catalogMediaFamilyForKind(normalizedKind);
  final formats = physicalMediaFormatsFromCatalog(catalog,
      kind: normalizedKind, mediaFamily: mediaFamily);
  if (formats.isNotEmpty) {
    return formats;
  }
  return fallbackPhysicalMediaFormatsForKind(normalizedKind);
}

List<CatalogMediaType> _normalizeCatalogMediaTypes(
  List<CatalogMediaType> catalog,
) {
  final mergedByKind = <String, CatalogMediaType>{};
  for (final type in catalog) {
    final normalized = _normalizeCatalogMediaType(type);
    final existing = mergedByKind[normalized.kind];
    if (existing == null) {
      mergedByKind[normalized.kind] = normalized;
      continue;
    }
    mergedByKind[normalized.kind] = CatalogMediaType(
      kind: normalized.kind,
      singularLabel: existing.singularLabel,
      pluralLabel: existing.pluralLabel,
      routeSegments: {
        ...existing.routeSegments,
        ...normalized.routeSegments,
      }.toList(growable: false),
      defaultProvider: existing.defaultProvider ?? normalized.defaultProvider,
      providers: {
        ...existing.providers,
        ...normalized.providers,
      }.toList(growable: false),
      providerSearchPolicy: existing.providerSearchPolicy,
      isTopLevel: existing.isTopLevel || normalized.isTopLevel,
      legacyOf: existing.legacyOf ?? normalized.legacyOf,
      physicalFormats: [
        ...existing.physicalFormats,
        for (final format in normalized.physicalFormats)
          if (!existing.physicalFormats.any((existingFormat) => existingFormat.id == format.id))
            format,
      ],
    );
  }
  return mergedByKind.values.toList(growable: false);
}

CatalogMediaType _normalizeCatalogMediaType(CatalogMediaType type) {
  final normalized = normalizeCatalogMediaTypeDefaults(type);
  final rawKind = normalized.kind.trim().toLowerCase();
  if (rawKind == 'manga') {
    return CatalogMediaType(
      kind: 'comic',
      singularLabel: 'Comic',
      pluralLabel: 'Comics',
      routeSegments: ['comics', 'comic', ...normalized.routeSegments],
      defaultProvider: normalized.defaultProvider,
      providers: normalized.providers,
      providerSearchPolicy: normalized.providerSearchPolicy,
      isTopLevel: false,
      legacyOf: 'comic',
      physicalFormats: normalized.physicalFormats,
    );
  }
  if (rawKind == 'anime') {
    return CatalogMediaType(
      kind: 'movie',
      singularLabel: 'Movie',
      pluralLabel: 'Movies',
      routeSegments: ['movies', 'movie', ...normalized.routeSegments],
      defaultProvider: normalized.defaultProvider,
      providers: normalized.providers,
      providerSearchPolicy: normalized.providerSearchPolicy,
      isTopLevel: false,
      legacyOf: 'movie',
      physicalFormats: normalized.physicalFormats,
    );
  }
  return normalized;
}

const fallbackMediaCatalog = <CatalogMediaType>[
  CatalogMediaType(
    kind: 'comic',
    singularLabel: 'Comic',
    pluralLabel: 'Comics',
    routeSegments: ['comics', 'comic'],
    defaultProvider: 'gcd',
    providers: ['gcd', 'comicvine', 'mangadex', 'anilist', 'hardcover'],
  ),
  CatalogMediaType(
    kind: 'movie',
    singularLabel: 'Movie',
    pluralLabel: 'Movies',
    routeSegments: ['movies', 'movie'],
    defaultProvider: 'tmdb',
    providers: ['tmdb', 'anilist'],
    physicalFormats: fallbackVideoCatalogPhysicalFormats,
  ),
  CatalogMediaType(
    kind: 'tv',
    singularLabel: 'TV Show',
    pluralLabel: 'TV Shows',
    routeSegments: ['tv', 'shows', 'series'],
    defaultProvider: 'tmdb',
    providers: ['tmdb'],
    physicalFormats: fallbackVideoCatalogPhysicalFormats,
  ),
  CatalogMediaType(
    kind: 'game',
    singularLabel: 'Game',
    pluralLabel: 'Games',
    routeSegments: ['games', 'game'],
    defaultProvider: 'igdb',
    providers: ['igdb'],
  ),
  CatalogMediaType(
    kind: 'boardgame',
    singularLabel: 'Board Game',
    pluralLabel: 'Board Games',
    routeSegments: ['board-games', 'boardgames', 'boardgame'],
    defaultProvider: 'bgg',
    providers: ['bgg'],
  ),
  CatalogMediaType(
    kind: 'book',
    singularLabel: 'Book',
    pluralLabel: 'Books',
    routeSegments: ['books', 'book'],
    defaultProvider: 'openlibrary',
    providers: ['openlibrary'],
  ),
  CatalogMediaType(
    kind: 'music',
    singularLabel: 'Music',
    pluralLabel: 'Music',
    routeSegments: ['music'],
    defaultProvider: 'musicbrainz',
    providers: ['musicbrainz'],
  ),
];

const fallbackVideoCatalogPhysicalFormats = <CatalogPhysicalFormat>[
  CatalogPhysicalFormat(
    id: 'dvd',
    label: 'DVD',
    mediaFamily: 'video',
    variantType: 'physical',
  ),
  CatalogPhysicalFormat(
    id: 'blu-ray',
    label: 'Blu-ray',
    mediaFamily: 'video',
    variantType: 'physical',
    aliases: ['bluray', 'blu ray'],
  ),
  CatalogPhysicalFormat(
    id: '4k-uhd',
    label: '4K UHD',
    mediaFamily: 'video',
    variantType: 'physical',
    aliases: ['4k', 'uhd', '4k blu-ray', '4k bluray', 'ultra hd'],
  ),
  CatalogPhysicalFormat(
    id: 'vhs',
    label: 'VHS',
    mediaFamily: 'video',
    variantType: 'physical',
  ),
  CatalogPhysicalFormat(
    id: 'laserdisc',
    label: 'LaserDisc',
    mediaFamily: 'video',
    variantType: 'physical',
  ),
  CatalogPhysicalFormat(
    id: 'digital',
    label: 'Digital',
    mediaFamily: 'video',
    variantType: 'digital',
  ),
];
