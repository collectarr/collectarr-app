import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/library_catalog_resolution.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/library_type_registry.dart';
import 'package:collectarr_app/features/library/physical_media_formats.dart';
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
      _cachedMediaCatalogBaseUrl = api.baseUrl;
      _cachedMediaCatalog = catalog;
      return catalog;
    }
  } catch (_) {
    // Keep the app usable when Core is offline; callers can invalidate to retry.
  }
  return fallbackMediaCatalog;
});

final resolvedLibraryTypesProvider = Provider<LibraryTypeRegistry>((ref) {
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
  String kind,
) {
  final mediaFamily = kind == 'music' ? 'audio' : 'video';
  final formats =
      physicalMediaFormatsFromCatalog(catalog, kind: kind, mediaFamily: mediaFamily);
  if (formats.isNotEmpty) {
    return formats;
  }
  if (kind == 'movie' || kind == 'tv' || kind == 'bluray') {
    return videoPhysicalMediaFormats;
  }
  if (kind == 'music') {
    return musicPhysicalMediaFormats;
  }
  return const [];
}

const fallbackMediaCatalog = <CatalogMediaType>[
  CatalogMediaType(
    kind: 'comic',
    singularLabel: 'Comic',
    pluralLabel: 'Comics',
    routeSegments: ['comics', 'comic'],
    defaultProvider: 'gcd',
    providers: ['gcd', 'comicvine'],
  ),
  CatalogMediaType(
    kind: 'manga',
    singularLabel: 'Manga',
    pluralLabel: 'Manga',
    routeSegments: ['manga'],
    defaultProvider: 'anilist',
    providers: ['anilist', 'comicvine'],
  ),
  CatalogMediaType(
    kind: 'anime',
    singularLabel: 'Anime',
    pluralLabel: 'Anime',
    routeSegments: ['anime'],
    defaultProvider: 'anilist',
    providers: ['anilist', 'tmdb'],
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
    singularLabel: 'Music Release',
    pluralLabel: 'Music Releases',
    routeSegments: ['music'],
    defaultProvider: 'musicbrainz',
    providers: ['musicbrainz'],
  ),
  CatalogMediaType(
    kind: 'bluray',
    singularLabel: 'Legacy Blu-ray',
    pluralLabel: 'Legacy Blu-rays',
    routeSegments: ['blu-ray', 'blu-rays', 'bluray'],
    isTopLevel: false,
    legacyOf: 'movie',
    physicalFormats: [
      CatalogPhysicalFormat(
        id: 'blu-ray',
        label: 'Blu-ray',
        mediaFamily: 'video',
        variantType: 'physical',
        aliases: ['bluray', 'blu ray'],
      ),
    ],
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
