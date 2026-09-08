import 'package:collectarr_app/features/library/kinds/anime/data/providers/anilist/anime_anilist_mapper.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/providers/adapters/anilist/anilist_provider.dart';
import 'package:collectarr_app/features/providers/domain/contracts/metadata_provider.dart';
import 'package:collectarr_app/features/providers/transport/normalized_provider_envelope_v1.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_result.dart';

/// Kind-owned facade over the shared AniList transport.
final class AnimeAniListIntegration {
  AnimeAniListIntegration({MetadataProvider? provider})
      : _provider = provider ?? AniListProvider();

  final MetadataProvider _provider;

  Future<AnimeMedia> fetchMedia(String providerItemId) async {
    final envelope = await _provider.fetchItem(
      providerItemId,
      kind: CatalogMediaKind.anime,
    );
    return AnimeAniListMapper.fromEnvelope(envelope);
  }

  Future<List<ProviderSearchResult>> search(String query, {int limit = 25}) {
    return _provider.search(
      query,
      kind: CatalogMediaKind.anime,
      limit: limit,
    );
  }

  AnimeMedia mapEnvelope(NormalizedProviderEnvelopeV1 envelope) {
    return AnimeAniListMapper.fromEnvelope(envelope);
  }
}
