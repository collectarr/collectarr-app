import 'package:collectarr_app/features/library/config/library_metadata_provider_models.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_registry.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';

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
  description: 'Personal non-commercial comics enrichment',
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
  description: 'Live manga metadata and chapter feed provider for comics',
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
  description: 'Live book and comic metadata provider',
  supportedKinds: {'book', 'manga'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary:
        'Book and comic metadata with attribution and API key requirements',
    requiresAttribution: true,
  ),
);

const anilistMetadataProvider = LibraryMetadataProviderOption(
  id: 'anilist',
  label: 'AniList',
  description: 'Live anime and manga metadata provider for movies and comics',
  supportedKinds: {'manga', 'anime'},
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Public anime/manga metadata with attribution requirements',
    requiresAttribution: true,
  ),
);

const tmdbMetadataProvider = LibraryMetadataProviderOption(
  id: 'tmdb',
  label: 'TMDb',
  description: 'Live movie and TV metadata provider',
  supportedKinds: {'movie', 'tv', 'anime'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary:
        'Live movie/TV metadata provider; physical media is tracked as editions',
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
  const LibraryMetadataProviderRegistry([this._registry]);

  final ProviderConnectorRegistry? _registry;

  ProviderConnectorRegistry get registry =>
      _registry ?? defaultProviderConnectorRegistry;

  LibraryMetadataProviderOption? byId(String id) {
    final connector = registry.get(id);
    if (connector == null) return null;
    return LibraryMetadataProviderOption.fromConnector(connector);
  }

  List<LibraryMetadataProviderOption> forKind(String kind) {
    final connectors = registry.getForKind(kind);
    return [
      for (final connector in connectors)
        if (connector.supportsMetadata)
          LibraryMetadataProviderOption.fromConnector(connector),
    ];
  }

  List<String> get supportedKinds => registry.supportedKinds;
}

const collectarrMetadataProviderRegistry = LibraryMetadataProviderRegistry();
