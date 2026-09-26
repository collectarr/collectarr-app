import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_mapper.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

CatalogSearchCandidate musicCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.kindCapability.mapTransport((transport) {
    final group = MusicCatalogMapper.mapMetadataItemToMusic(transport);
    return item.kindCapability.withKindMetadata(group);
  });
}

CatalogSearchCandidate musicCatalogTransportFromTypedProviderCandidate(
  ProviderSearchCandidate candidate,
) {
  if (candidate case final MusicReleaseCandidate releaseCandidate) {
    final album = MusicMusicBrainzMapper.albumFromCandidate(releaseCandidate);
    return CatalogSearchCandidate.fromSummary(
      summary: CatalogDisplaySummary.root(
        id: album.id.value,
        kind: CatalogMediaKind.music,
        primaryLabel: album.title,
        subtitle: album.format,
        imageUrl: album.coverImageUrl,
      ),
      transport: CatalogItemDto.raw(
        id: album.id.value,
        mediaKind: CatalogMediaKind.music,
        common: CatalogCommonDto(
          title: album.title,
          coverImageUrl: album.coverImageUrl,
          releaseDate: album.releaseDateTime,
          releaseYear: album.releaseDate?.year,
        ),
        payload: album.toJson(),
        kindMetadata: album,
      ),
    );
  }
  throw StateError(
    'Music Add requires one concrete album release candidate.',
  );
}
