import 'package:flutter/material.dart';

import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_registry.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';

export 'package:collectarr_app/features/providers/domain/models/provider_id.dart';

enum ProviderImportAvailability {
  available,
  comingSoon,
}

class ProviderImportDescriptor {
  const ProviderImportDescriptor({
    required this.id,
    required this.title,
    required this.summary,
    this.availability = ProviderImportAvailability.available,
    this.connector,
  });

  final ProviderId id;
  final String title;
  final String summary;
  final ProviderImportAvailability availability;
  final ProviderConnector? connector;

  ProviderConnector? _resolveConnector([ProviderConnectorRegistry? registry]) {
    if (connector != null) return connector;
    final reg = registry ?? defaultProviderConnectorRegistry;
    return reg.getById(id);
  }

  bool canImportPersonalListWith([ProviderConnectorRegistry? registry]) =>
      _resolveConnector(registry)?.supportsPersonalListFileImport ?? false;

  bool canPullWith([ProviderConnectorRegistry? registry]) =>
      _resolveConnector(registry)?.supportsPersonalRead ?? false;

  bool canPushWith([ProviderConnectorRegistry? registry]) =>
      _resolveConnector(registry)?.supportsPersonalWrite ?? false;

  bool get canImportPersonalList => canImportPersonalListWith();
  bool get canPull => canPullWith();
  bool get canPush => canPushWith();

  bool get supportsAccountSync => canPull;
  bool get supportsPersonalListFileImport => canImportPersonalList;
}

/// Icon data for each provider (Material Icons fallback for missing logos).
IconData providerImportIcon(ProviderId id) => id.icon;

const providerImportDescriptors = <ProviderImportDescriptor>[
  ProviderImportDescriptor(
    id: ProviderId.tmdb,
    title: 'TMDB',
    summary:
        'Import rated and watchlist movies from TMDB account sync or TMDB export files.',
  ),
  ProviderImportDescriptor(
    id: ProviderId.trakt,
    title: 'Trakt',
    summary: 'Import TV shows and movies.',
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderId.simkl,
    title: 'SIMKL',
    summary: 'Import TV shows, movies and anime.',
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderId.myAnimeList,
    title: 'MyAnimeList',
    summary: 'Import anime and manga XML exports.',
    availability: ProviderImportAvailability.available,
  ),
  ProviderImportDescriptor(
    id: ProviderId.aniList,
    title: 'AniList',
    summary: 'Import anime and manga XML exports.',
    availability: ProviderImportAvailability.available,
  ),
  ProviderImportDescriptor(
    id: ProviderId.kitsu,
    title: 'Kitsu',
    summary: 'Import anime and manga.',
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderId.imdb,
    title: 'IMDB',
    summary: 'Import movies and TV shows from your ratings.',
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderId.goodReads,
    title: 'GoodReads',
    summary: 'Import from GoodReads backup.',
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderId.howLongToBeat,
    title: 'HowLongToBeat',
    summary: 'Import games.',
    availability: ProviderImportAvailability.comingSoon,
  ),
  ProviderImportDescriptor(
    id: ProviderId.steam,
    title: 'Steam',
    summary: 'Import games from your Steam library.',
    availability: ProviderImportAvailability.comingSoon,
  ),
];
