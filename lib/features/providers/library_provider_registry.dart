import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_connector.dart';
import 'package:collectarr_app/features/providers/runtime/provider_http_client.dart';
import 'package:collectarr_app/features/providers/runtime/provider_rate_limiter.dart';
import 'package:collectarr_app/features/library/kinds/music/integrations/musicbrainz/music_musicbrainz_provider_adapter.dart';

/// Builds the MusicBrainz connector at the provider composition boundary.
///
/// The runtime provider registry only asks for a connector. The protocol
/// adapter and the Music-owned candidate mapping stay composed here, without
/// leaking a kind import into the generic provider runtime.
ProviderConnector buildMusicBrainzProviderConnector({
  ProviderHttpClient? httpClient,
  ProviderRateLimiterRegistry? rateLimiterRegistry,
}) {
  return MusicMusicBrainzProviderAdapter(
    provider: MusicBrainzProvider(
      httpClient: httpClient,
      rateLimiterRegistry: rateLimiterRegistry,
    ),
  ).toConnector();
}
