import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

const libraryAddVideoMediaOptionId = 'video.media';
const libraryAddVideoSeasonOptionId = 'video.season';
const libraryAddVideoReleaseOptionId = 'video.release';

enum LibraryAddVideoResultScope { media, season, release }

typedef LibraryAddVideoCoreScopeResolver = LibraryAddVideoResultScope Function(
    CatalogItem item);

typedef LibraryAddVideoProviderScopeResolver = LibraryAddVideoResultScope
    Function(ProviderCandidate candidate);

LibraryAddResultPolicy buildLibraryAddVideoResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required LibraryAddVideoCoreScopeResolver coreScopeForItem,
  required LibraryAddVideoProviderScopeResolver providerScopeForCandidate,
  required String Function(CatalogItem item) coreGroupTitleBuilder,
  required bool Function(ProviderCandidate candidate) providerCandidateIsGroup,
  int Function(ProviderCandidate left, ProviderCandidate right)?
      providerCandidateComparator,
}) {
  return LibraryAddResultPolicy(
    useGridResults: true,
    options: [
      LibraryAddResultOption(
        id: libraryAddVideoMediaOptionId,
        label: mediaLabel,
      ),
      if (supportsSeasonScope)
        const LibraryAddResultOption(
          id: libraryAddVideoSeasonOptionId,
          label: 'Seasons',
        ),
      const LibraryAddResultOption(
        id: libraryAddVideoReleaseOptionId,
        label: 'Releases',
      ),
    ],
    coreResultVisibility: (item, context) => context.optionIsEnabled(
      _videoScopeOptionId(
        coreScopeForItem(item),
        supportsSeasonScope: supportsSeasonScope,
      ),
    ),
    providerResultVisibility: (candidate, context) => context.optionIsEnabled(
      _videoScopeOptionId(
        providerScopeForCandidate(candidate),
        supportsSeasonScope: supportsSeasonScope,
      ),
    ),
    coreGroupTitleBuilder: coreGroupTitleBuilder,
    providerGroupTitleBuilder: _videoProviderGroupTitle,
    providerCandidateIsGroup: providerCandidateIsGroup,
    providerCandidateComparator: providerCandidateComparator,
  );
}

String _videoScopeOptionId(
  LibraryAddVideoResultScope scope, {
  required bool supportsSeasonScope,
}) {
  return switch (scope) {
    LibraryAddVideoResultScope.media => libraryAddVideoMediaOptionId,
    LibraryAddVideoResultScope.season => supportsSeasonScope
        ? libraryAddVideoSeasonOptionId
        : libraryAddVideoMediaOptionId,
    LibraryAddVideoResultScope.release => libraryAddVideoReleaseOptionId,
  };
}

String _videoProviderGroupTitle(ProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return candidate.title.trim();
}

bool libraryAddVideoProviderCandidateIsGroup(ProviderCandidate candidate) {
  final candidateType = candidate.candidateType?.trim().toLowerCase();
  if (candidateType == 'series' ||
      candidateType == 'show' ||
      candidateType == 'movie') {
    return true;
  }
  if (candidateType == 'season' ||
      candidateType == 'episode' ||
      candidateType == 'release' ||
      candidateType == 'edition' ||
      candidateType == 'issue') {
    return false;
  }
  return (candidate.issueNumber?.trim().isEmpty ?? true) &&
      !candidate.isVariant;
}
