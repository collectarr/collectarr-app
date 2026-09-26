import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

/// Music Add presents each concrete album/release as an independent result.
/// The release-group relationship remains available on the provider
/// candidate for provenance and hydration, but it does not control grouping.
final musicAddResultPolicy = LibraryAddResultPolicy(
  coreGroupTitleBuilder: (item) => item.summary.primaryLabel,
  coreResultKeyBuilder: (item) => item.reference.id,
  coreGroupArtistBuilder: _musicCoreGroupArtist,
  typedProviderGroupTitleBuilder: (candidate) => candidate.title,
  typedProviderGroupArtistBuilder: _musicTypedProviderArtist,
  typedProviderGroupKeyBuilder: (candidate) => candidate.providerItemId,
  typedProviderCandidateComparator: _compareMusicCandidates,
);

String? _musicCoreGroupArtist(CatalogSearchCandidate item) {
  final album = item.kindCapability
      .mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
  return album.artist;
}

String? _musicTypedProviderArtist(ProviderSearchCandidate candidate) =>
    candidate is MusicReleaseCandidate ? candidate.artist : null;

int _compareMusicCandidates(
  ProviderSearchCandidate left,
  ProviderSearchCandidate right,
) {
  final titleComparison = left.title.toLowerCase().compareTo(
        right.title.toLowerCase(),
      );
  if (titleComparison != 0) return titleComparison;
  return left.providerItemId.compareTo(right.providerItemId);
}
