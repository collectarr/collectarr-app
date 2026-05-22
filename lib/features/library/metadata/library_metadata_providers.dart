import 'package:collectarr_app/features/library/config/library_type_config.dart';

const gcdMetadataProvider = LibraryMetadataProviderOption(
  id: 'gcd',
  label: 'GCD',
  description: 'Grand Comics Database',
  supportedKinds: {'comic'},
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'CC BY-SA comics metadata with attribution requirements',
    requiresAttribution: true,
  ),
);

const comicVineMetadataProvider = LibraryMetadataProviderOption(
  id: 'comicvine',
  label: 'Comic Vine',
  description: 'Personal non-commercial comics and manga enrichment',
  supportedKinds: {'comic', 'manga'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Personal non-commercial use only',
    requiresAttribution: true,
    nonCommercialOnly: true,
  ),
);

const mangadexMetadataProvider = LibraryMetadataProviderOption(
  id: 'mangadex',
  label: 'MangaDex',
  description: 'Live manga metadata and chapter feed provider',
  supportedKinds: {'manga'},
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Public manga metadata with attribution requirements',
    requiresAttribution: true,
  ),
);

const igdbMetadataProvider = LibraryMetadataProviderOption(
  id: 'igdb',
  label: 'IGDB',
  description: 'Live games metadata provider',
  supportedKinds: {'game'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary:
        'Game metadata with attribution and non-commercial API constraints',
    requiresAttribution: true,
  ),
);

const bggMetadataProvider = LibraryMetadataProviderOption(
  id: 'bgg',
  label: 'BoardGameGeek',
  description: 'Live board game metadata provider',
  supportedKinds: {'boardgame'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Board game metadata with attribution and API constraints',
    requiresAttribution: true,
  ),
);

const openLibraryMetadataProvider = LibraryMetadataProviderOption(
  id: 'openlibrary',
  label: 'Open Library',
  description: 'Live books metadata provider',
  supportedKinds: {'book'},
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Book metadata with attribution requirements',
    requiresAttribution: true,
  ),
);

const hardcoverMetadataProvider = LibraryMetadataProviderOption(
  id: 'hardcover',
  label: 'Hardcover',
  description: 'Live book and manga metadata provider',
  supportedKinds: {'book', 'manga'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Book and manga metadata with attribution and API key requirements',
    requiresAttribution: true,
  ),
);

const anilistMetadataProvider = LibraryMetadataProviderOption(
  id: 'anilist',
  label: 'AniList',
  description: 'Live anime and manga metadata provider',
  supportedKinds: {'manga', 'anime'},
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Public anime/manga metadata with attribution requirements',
    requiresAttribution: true,
  ),
);

const tmdbMetadataProvider = LibraryMetadataProviderOption(
  id: 'tmdb',
  label: 'TMDb',
  description: 'Live movie, TV, and anime metadata provider',
  supportedKinds: {'movie', 'tv', 'anime'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary:
        'Live movie/TV/anime metadata provider; physical media is tracked as editions',
    requiresAttribution: true,
  ),
);

const musicBrainzMetadataProvider = LibraryMetadataProviderOption(
  id: 'musicbrainz',
  label: 'MusicBrainz',
  description: 'Live music release metadata provider',
  supportedKinds: {'music'},
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Music metadata with attribution requirements',
    requiresAttribution: true,
  ),
);

const collectarrKnownMetadataProviders = [
  gcdMetadataProvider,
  mangadexMetadataProvider,
  anilistMetadataProvider,
  comicVineMetadataProvider,
  igdbMetadataProvider,
  bggMetadataProvider,
  openLibraryMetadataProvider,
  hardcoverMetadataProvider,
  tmdbMetadataProvider,
  musicBrainzMetadataProvider,
];

class LibraryMetadataProviderRegistry {
  const LibraryMetadataProviderRegistry(this.providers);

  final List<LibraryMetadataProviderOption> providers;

  LibraryMetadataProviderOption? byId(String id) {
    final normalized = id.trim();
    for (final provider in providers) {
      if (provider.id == normalized) {
        return provider;
      }
    }
    return null;
  }

  List<LibraryMetadataProviderOption> forKind(String kind) {
    final normalized = kind.trim();
    return [
      for (final provider in providers)
        if (provider.supportsKind(normalized)) provider,
    ];
  }

  List<String> get supportedKinds {
    final kinds = <String>{};
    for (final provider in providers) {
      kinds.addAll(provider.supportedKinds);
    }
    return kinds.toList(growable: false);
  }
}

const collectarrMetadataProviderRegistry = LibraryMetadataProviderRegistry(
  collectarrKnownMetadataProviders,
);
