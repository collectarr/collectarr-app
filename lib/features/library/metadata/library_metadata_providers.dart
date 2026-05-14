import 'package:collectarr_app/features/library/library_type_config.dart';

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
  description: 'Personal non-commercial enrichment',
  supportedKinds: {'comic'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Personal non-commercial use only',
    requiresAttribution: true,
    nonCommercialOnly: true,
  ),
);

const igdbMetadataProvider = LibraryMetadataProviderOption(
  id: 'igdb',
  label: 'IGDB',
  description: 'Planned games metadata provider',
  supportedKinds: {'game'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Planned provider with attribution and commercial-use constraints',
    requiresAttribution: true,
  ),
);

const openLibraryMetadataProvider = LibraryMetadataProviderOption(
  id: 'openlibrary',
  label: 'Open Library',
  description: 'Planned books metadata provider',
  supportedKinds: {'book'},
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Planned books metadata provider with attribution requirements',
    requiresAttribution: true,
  ),
);

const anilistMetadataProvider = LibraryMetadataProviderOption(
  id: 'anilist',
  label: 'AniList',
  description: 'Planned manga metadata provider',
  supportedKinds: {'manga'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Planned manga metadata provider with attribution requirements',
    requiresAttribution: true,
  ),
);

const tmdbMetadataProvider = LibraryMetadataProviderOption(
  id: 'tmdb',
  label: 'TMDb',
  description: 'Planned movie and Blu-ray metadata provider',
  supportedKinds: {'movie', 'bluray'},
  requiresApiKey: true,
  usagePolicy: LibraryMetadataProviderUsagePolicy(
    summary: 'Planned provider with attribution and redistribution constraints',
    requiresAttribution: true,
  ),
);

const collectarrKnownMetadataProviders = [
  gcdMetadataProvider,
  comicVineMetadataProvider,
  igdbMetadataProvider,
  openLibraryMetadataProvider,
  anilistMetadataProvider,
  tmdbMetadataProvider,
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
