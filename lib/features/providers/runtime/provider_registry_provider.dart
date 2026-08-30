import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adapters/anilist/anilist_provider.dart';
import '../adapters/bgg/bgg_provider.dart';
import '../adapters/comicvine/comicvine_provider.dart';
import '../adapters/gcd/gcd_provider.dart';
import '../adapters/hardcover/hardcover_provider.dart';
import '../adapters/igdb/igdb_provider.dart';
import '../adapters/mangadex/mangadex_provider.dart';
import '../adapters/musicbrainz/musicbrainz_provider.dart';
import '../adapters/openlibrary/openlibrary_provider.dart';
import '../adapters/tmdb/tmdb_provider.dart';
import '../credentials/models/bgg_credentials.dart';
import '../credentials/models/comicvine_credentials.dart';
import '../credentials/models/hardcover_credentials.dart';
import '../credentials/models/igdb_credentials.dart';
import '../credentials/models/tmdb_credentials.dart';
import '../credentials/secure_provider_credential_store.dart';
import '../domain/contracts/provider_registry.dart';

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
}) {
  final registry = InMemoryProviderConnectorRegistry();

  registry.register(OpenLibraryProvider().toConnector());
  registry.register(AniListProvider().toConnector());
  registry.register(MusicBrainzProvider().toConnector());
  registry.register(MangaDexProvider().toConnector());
  registry.register(GCDProvider().toConnector());
  registry.register(ComicVineProvider(credentials: comicVineCredentials).toConnector());
  registry.register(HardcoverProvider(credentials: hardcoverCredentials).toConnector());
  registry.register(TMDbProvider(credentials: tmdbCredentials).toConnector());
  registry.register(BGGProvider(credentials: bggCredentials).toConnector());
  registry.register(IGDBProvider(credentials: igdbCredentials).toConnector());

  return registry;
}

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
