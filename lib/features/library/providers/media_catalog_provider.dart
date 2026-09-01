import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/logging/recoverable_error.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_catalog_kind_defaults.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/_shared/video/video_physical_media_formats.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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
      message:
          'Failed to load media catalog from metadata server; using fallback catalog.',
      error: error,
      stackTrace: stackTrace,
    );
  }
  return fallbackMediaCatalog;
});

final resolvedLibraryTypesProvider = Provider<LibraryKindRegistry>((ref) {
  final catalog = _catalogOrFallback(ref.watch(mediaCatalogProvider));
  return defaultLibraryKindRegistry.resolveWithCatalog(catalog);
});

final resolvedLibraryTypeProvider =
    Provider.family<LibraryKindRuntime, LibraryKindRuntime>((ref, type) {
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
  final mediaKind = catalogMediaKindFromValue(kind);
  final mediaFamily = catalogMediaFamilyForKind(mediaKind);
  final formats = physicalMediaFormatsFromCatalog(catalog,
      kind: mediaKind.apiValue, mediaFamily: mediaFamily);
  if (formats.isNotEmpty) {
    return formats;
  }
  return fallbackPhysicalMediaFormatsForKind(mediaKind);
}

List<CatalogMediaType> _normalizeCatalogMediaTypes(
  List<CatalogMediaType> catalog,
) {
  return [
    for (final type in catalog) normalizeCatalogMediaTypeDefaults(type),
  ];
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
    kind: 'manga',
    singularLabel: 'Manga',
    pluralLabel: 'Manga',
    routeSegments: ['manga'],
    defaultProvider: 'hardcover',
    providers: ['hardcover', 'comicvine', 'anilist', 'mangadex'],
  ),
  CatalogMediaType(
    kind: 'movie',
    singularLabel: 'Movie',
    pluralLabel: 'Movies',
    routeSegments: ['movies', 'movie'],
    defaultProvider: 'tmdb',
    providers: ['tmdb'],
    physicalFormats: fallbackVideoCatalogPhysicalFormats,
  ),
  CatalogMediaType(
    kind: 'tv',
    singularLabel: 'TV Show',
    pluralLabel: 'TV Shows',
    routeSegments: ['tv', 'tv-shows', 'tvshows'],
    defaultProvider: 'tmdb',
    providers: ['tmdb'],
    physicalFormats: fallbackVideoCatalogPhysicalFormats,
  ),
  CatalogMediaType(
    kind: 'anime',
    singularLabel: 'Anime',
    pluralLabel: 'Anime',
    routeSegments: ['anime'],
    defaultProvider: 'anilist',
    providers: ['anilist'],
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
