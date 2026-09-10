import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_mapper.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/models/musicbrainz_release.dart';
import 'package:collectarr_app/features/providers/adapters/musicbrainz/musicbrainz_provider.dart';
import 'package:collectarr_app/features/providers/domain/contracts/metadata_provider.dart';
import 'package:collectarr_app/features/providers/transport/provider_metadata_envelope.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';

/// Kind-owned facade over the shared MusicBrainz transport.
final class MusicMusicBrainzIntegration {
  MusicMusicBrainzIntegration({MetadataProvider? provider})
      : _provider = provider ?? MusicBrainzProvider();

  final MetadataProvider _provider;

  Future<MusicRelease> fetchRelease(String providerItemId) async {
    final envelope = await _provider.fetchItem(
      providerItemId,
      kind: CatalogMediaKind.music,
    );
    return MusicMusicBrainzMapper.fromEnvelope(envelope);
  }

  Future<List<ProviderSearchResult>> search(
    String query, {
    int limit = 25,
  }) {
    return _provider.search(
      query,
      kind: CatalogMediaKind.music,
      limit: limit,
    );
  }

  MusicRelease mapNative(MusicBrainzRelease release) {
    return MusicMusicBrainzMapper.fromNative(release);
  }

  MusicRelease mapEnvelope(ProviderMetadataEnvelope envelope) {
    return MusicMusicBrainzMapper.fromEnvelope(envelope);
  }
}
