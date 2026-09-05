import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/anilist/anilist_file_import_capability.dart';
import '../adapters/anilist/anilist_provider.dart';
import '../adapters/anilist/anilist_sync_adapter.dart';
import '../adapters/bgg/bgg_provider.dart';
import '../adapters/comicvine/comicvine_provider.dart';
import '../adapters/gcd/gcd_provider.dart';
import '../adapters/hardcover/hardcover_provider.dart';
import '../adapters/igdb/igdb_provider.dart';
import '../adapters/mangadex/mangadex_provider.dart';
import '../adapters/musicbrainz/musicbrainz_provider.dart';
import '../adapters/myanimelist/myanimelist_file_import_capability.dart';
import '../adapters/openlibrary/openlibrary_provider.dart';
import '../adapters/tmdb/tmdb_file_import_capability.dart';
import '../adapters/tmdb/tmdb_provider.dart';
import '../credentials/models/bgg_credentials.dart';
import '../credentials/models/comicvine_credentials.dart';
import '../credentials/models/hardcover_credentials.dart';
import '../credentials/models/igdb_credentials.dart';
import '../credentials/models/tmdb_credentials.dart';
import '../credentials/secure_provider_credential_store.dart';
import '../domain/contracts/provider_connector.dart';
import '../domain/contracts/provider_registry.dart';
import '../domain/models/provider_descriptor.dart';
import '../domain/models/provider_id.dart';
import 'provider_http_client.dart';
import 'provider_rate_limiter.dart';

final secureProviderCredentialStoreProvider =
    Provider<SecureProviderCredentialStore>((ref) {
  return SecureProviderCredentialStore();
});

/// Constructs an [InMemoryProviderConnectorRegistry] populated with all supported connectors.
ProviderConnectorRegistry buildDefaultProviderRegistry({
  ComicVineCredentials? comicVineCredentials,
  HardcoverCredentials? hardcoverCredentials,
  TmdbCredentials? tmdbCredentials,
  BggCredentials? bggCredentials,
  IgdbCredentials? igdbCredentials,
  ProviderHttpClient? httpClient,
  String? anilistAccessToken,
}) {
  final registry = InMemoryProviderConnectorRegistry();

  final anilistClient = httpClient ??
      ProviderHttpClient(
        provider: 'anilist',
        baseUrl: 'https://graphql.anilist.co',
        rateLimiter: ProviderRateLimiter.aniList(),
      );
  final anilistSync = AniListSyncAdapter(
    client: anilistClient,
    accessToken: anilistAccessToken,
  );

  registry.register(GCDProvider(httpClient: httpClient).toConnector());
  registry.register(MangaDexProvider(httpClient: httpClient).toConnector());
  registry.register(
    AniListProvider(httpClient: httpClient).toConnector(
      personalRead: anilistSync,
      personalWrite: anilistSync,
      personalListFileImport: const AniListPersonalListFileImportCapability(),
    ),
  );
  registry.register(
    ComicVineProvider(
      credentials: comicVineCredentials,
      httpClient: httpClient,
    ).toConnector(),
  );
  registry.register(
    IGDBProvider(
      credentials: igdbCredentials,
      httpClient: httpClient,
    ).toConnector(),
  );
  registry.register(
    BGGProvider(
      credentials: bggCredentials,
      httpClient: httpClient,
    ).toConnector(),
  );
  registry.register(OpenLibraryProvider(httpClient: httpClient).toConnector());
  registry.register(
    HardcoverProvider(
      credentials: hardcoverCredentials,
      httpClient: httpClient,
    ).toConnector(),
  );
  registry.register(
    TMDbProvider(
      credentials: tmdbCredentials,
      httpClient: httpClient,
    ).toConnector(
      personalListFileImport: const TmdbPersonalListFileImportCapability(),
    ),
  );
  registry.register(MusicBrainzProvider(httpClient: httpClient).toConnector());

  registry.register(
    const ProviderConnector(
      id: ProviderId.myAnimeList,
      descriptor: ProviderDescriptor(
        name: 'myanimelist',
        displayName: 'MyAnimeList',
        kind: 'anime',
        supportedKinds: ['anime', 'manga'],
        supportsSearch: false,
        supportsIngest: true,
      ),
      personalListFileImport: MyAnimeListPersonalListFileImportCapability(),
    ),
  );

  return registry;
}

/// Global default instance of [ProviderConnectorRegistry] initialized with standard connectors.
final defaultProviderConnectorRegistry = buildDefaultProviderRegistry();

/// Asynchronous Riverpod provider supplying an initialized [ProviderRegistry]
/// populated with credentials from [SecureProviderCredentialStore].
final providerRegistryProvider = FutureProvider<ProviderRegistry>((ref) async {
  final store = ref.watch(secureProviderCredentialStoreProvider);

  final comicVine = await store.getComicVineCredentials();
  final hardcover = await store.getHardcoverCredentials();
  final tmdb = await store.getTmdbCredentials();
  final bgg = await store.getBggCredentials();
  final igdb = await store.getIgdbCredentials();

  return buildDefaultProviderRegistry(
    comicVineCredentials: comicVine,
    hardcoverCredentials: hardcover,
    tmdbCredentials: tmdb,
    bggCredentials: bgg,
    igdbCredentials: igdb,
  );
});
