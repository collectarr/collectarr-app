import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

const musicReleaseGroupCandidateType = 'release_group';
const musicReleaseCandidateType = 'release';

/// Music search is rooted at the MusicBrainz release-group boundary.
///
/// Core results already represent groups. Provider results are concrete
/// releases, so their parent hint is used to render the same group -> release
/// tree in Add.
final musicAddResultPolicy = LibraryAddResultPolicy(
  coreGroupTitleBuilder: _musicCoreGroupTitle,
  coreGroupArtistBuilder: _musicCoreGroupArtist,
  // The expanded group header is the MusicReleaseGroup result itself. The
  // synthetic group candidate remains selectable from that header so its
  // details can be shown, but it must not be duplicated as a child beside
  // the concrete MusicRelease rows.
  showProviderGroupCandidateAsChild: false,
  typedProviderGroupTitleBuilder: _musicTypedProviderGroupTitle,
  typedProviderGroupArtistBuilder: _musicTypedProviderGroupArtist,
  typedProviderGroupKeyBuilder: _musicTypedProviderGroupKey,
  typedProviderCandidateIsGroup: (candidate) =>
      candidate is MusicReleaseGroupCandidate,
  typedProviderGroupCandidateLabelBuilder: (candidate) =>
      '${candidate.title} (release group)',
  typedProviderGroupCandidateBadgeBuilder: (_) => 'release group',
  typedProviderCandidateComparator: _compareMusicTypedCandidates,
);

String _musicCoreGroupTitle(CatalogSearchCandidate item) {
  final group = item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
  final title = group.title.trim();
  return title.isEmpty ? item.title : title;
}

String? _musicCoreGroupArtist(CatalogSearchCandidate item) {
  final group = item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
  return group.artist;
}

String _musicTypedProviderGroupTitle(ProviderSearchCandidate candidate) {
  final title = switch (candidate) {
    MusicReleaseGroupCandidate group => group.title,
    MusicReleaseCandidate release => release.releaseGroupTitle ?? release.title,
    _ => candidate.title,
  }
      .trim();
  return title.isEmpty ? 'Untitled release group' : title;
}

String? _musicTypedProviderGroupArtist(ProviderSearchCandidate candidate) =>
    switch (candidate) {
      MusicReleaseGroupCandidate group => group.artist,
      MusicReleaseCandidate release => release.artist,
      _ => null,
    };

String _musicTypedProviderGroupKey(ProviderSearchCandidate candidate) =>
    switch (candidate) {
      MusicReleaseGroupCandidate group => group.identity.externalId,
      MusicReleaseCandidate release =>
        release.releaseGroupId ?? release.providerItemId,
      _ => candidate.providerItemId,
    };

int _compareMusicTypedCandidates(
  ProviderSearchCandidate left,
  ProviderSearchCandidate right,
) {
  final leftIsGroup = left is MusicReleaseGroupCandidate;
  final rightIsGroup = right is MusicReleaseGroupCandidate;
  if (leftIsGroup != rightIsGroup) return leftIsGroup ? -1 : 1;
  final titleComparison = left.title.toLowerCase().compareTo(
        right.title.toLowerCase(),
      );
  if (titleComparison != 0) return titleComparison;
  return left.providerItemId.compareTo(right.providerItemId);
}
