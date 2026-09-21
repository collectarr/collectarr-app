import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/library/kinds/music/data/providers/musicbrainz/music_musicbrainz_mapper.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

CatalogSearchCandidate musicCatalogTransportFromCoreItem(
  CatalogSearchCandidate item,
) {
  return item.mapTransport((transport) {
    final group = MusicCatalogMapper.mapMetadataItemToMusic(transport);
    return item.withKindMetadata(group);
  });
}

CatalogSearchCandidate musicCatalogTransportFromTypedProviderCandidate(
  ProviderSearchCandidate candidate,
) {
  if (candidate case final MusicReleaseCandidate releaseCandidate) {
    final release = MusicMusicBrainzMapper.fromCandidate(releaseCandidate);
    final group = MusicReleaseGroup(
      id: release.releaseGroupId,
      title: releaseCandidate.releaseGroupTitle ?? release.title,
      artist: releaseCandidate.artist,
      originalReleaseDate: release.releaseDate,
      genres: releaseCandidate.genres,
      coverImageUrl: release.coverImageUrl,
      releases: [release],
    );
    return CatalogSearchCandidate.fromKindProjection(
      id: releaseCandidate.localCatalogId,
      kind: CatalogMediaKind.music,
      title: group.title,
      synopsis: releaseCandidate.summary,
      coverImageUrl: group.coverImageUrl,
      releaseDate: group.releaseDate,
      kindMetadata: group,
    );
  }
  if (candidate case final MusicReleaseGroupCandidate groupCandidate) {
    final group = MusicMusicBrainzMapper.releaseGroupFromCandidate(
      groupCandidate,
    );
    return CatalogSearchCandidate.fromKindProjection(
      id: groupCandidate.localCatalogId,
      kind: CatalogMediaKind.music,
      title: group.title,
      synopsis: group.synopsis,
      coverImageUrl: group.coverImageUrl,
      releaseDate: group.releaseDate,
      kindMetadata: group,
    );
  }
  throw StateError(
    'Music provider candidates must be mapped by a kind-owned typed mapper.',
  );
}
