import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';

const musicReleaseGroupCandidateType = 'release_group';
const musicReleaseCandidateType = 'release';

/// Music search is rooted at the MusicBrainz release-group boundary.
///
/// Core results already represent groups. Provider results are concrete
/// releases, so their parent hint is used to render the same group -> release
/// tree in Add.
final musicAddResultPolicy = LibraryAddResultPolicy(
  coreGroupTitleBuilder: _musicCoreGroupTitle,
  providerGroupTitleBuilder: _musicProviderGroupTitle,
  providerGroupKeyBuilder: _musicProviderGroupKey,
  providerCandidateIsGroup: (candidate) =>
      candidate.candidateType == musicReleaseGroupCandidateType,
  // The expanded group header is the MusicReleaseGroup result itself. The
  // synthetic group candidate remains selectable from that header so its
  // details can be shown, but it must not be duplicated as a child beside
  // the concrete MusicRelease rows.
  showProviderGroupCandidateAsChild: false,
  providerGroupCandidateLabelBuilder: (candidate) =>
      '${candidate.title} (release group)',
  providerGroupCandidateBadgeBuilder: (_) => 'release group',
  providerCandidateComparator: _compareMusicCandidates,
);

String _musicCoreGroupTitle(CatalogSearchCandidate item) {
  final group = item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
  final title = group.title.trim();
  return title.isEmpty ? item.title : title;
}

String _musicProviderGroupTitle(ProviderCandidate candidate) {
  final parentTitle = candidate.parent?.title.trim();
  if (parentTitle != null && parentTitle.isNotEmpty) return parentTitle;
  final title = candidate.title.trim();
  return title.isEmpty ? 'Untitled release group' : title;
}

String _musicProviderGroupKey(ProviderCandidate candidate) {
  final parentId = candidate.parent?.id.trim();
  if (parentId != null && parentId.isNotEmpty) return parentId;
  return candidate.providerItemId.trim();
}

int _compareMusicCandidates(
  ProviderCandidate left,
  ProviderCandidate right,
) {
  final leftIsGroup = left.candidateType == musicReleaseGroupCandidateType;
  final rightIsGroup = right.candidateType == musicReleaseGroupCandidateType;
  if (leftIsGroup != rightIsGroup) return leftIsGroup ? -1 : 1;
  final titleComparison = left.title.toLowerCase().compareTo(
        right.title.toLowerCase(),
      );
  if (titleComparison != 0) return titleComparison;
  return left.providerItemId.compareTo(right.providerItemId);
}
