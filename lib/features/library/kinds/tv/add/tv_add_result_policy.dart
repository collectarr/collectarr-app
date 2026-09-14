import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';

const tvAddMediaOptionId = 'tv.media';
const tvAddSeasonOptionId = 'tv.season';
const tvAddReleaseOptionId = 'tv.release';

enum TvAddResultScope { media, season, release }

typedef TvAddCoreScopeResolver = TvAddResultScope Function(
    CatalogSearchCandidate item);

typedef TvAddProviderScopeResolver = TvAddResultScope Function(
    ProviderCandidate candidate);

LibraryAddResultPolicy buildTvAddResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required TvAddCoreScopeResolver coreScopeForItem,
  required TvAddProviderScopeResolver providerScopeForCandidate,
  required String Function(CatalogSearchCandidate item) coreGroupTitleBuilder,
  required bool Function(ProviderCandidate candidate) providerCandidateIsGroup,
  int Function(ProviderCandidate left, ProviderCandidate right)?
      providerCandidateComparator,
}) {
  return LibraryAddResultPolicy(
    useGridResults: true,
    options: [
      LibraryAddResultOption(
        id: tvAddMediaOptionId,
        label: mediaLabel,
      ),
      if (supportsSeasonScope)
        const LibraryAddResultOption(
          id: tvAddSeasonOptionId,
          label: 'Seasons',
        ),
      const LibraryAddResultOption(
        id: tvAddReleaseOptionId,
        label: 'Releases',
      ),
    ],
    coreResultVisibility: (item, context) => context.optionIsEnabled(
      _tvScopeOptionId(
        coreScopeForItem(item),
        supportsSeasonScope: supportsSeasonScope,
      ),
    ),
    providerResultVisibility: (candidate, context) => context.optionIsEnabled(
      _tvScopeOptionId(
        providerScopeForCandidate(candidate),
        supportsSeasonScope: supportsSeasonScope,
      ),
    ),
    coreGroupTitleBuilder: coreGroupTitleBuilder,
    providerGroupTitleBuilder: _tvProviderGroupTitle,
    providerCandidateIsGroup: providerCandidateIsGroup,
    providerCandidateComparator: providerCandidateComparator,
  );
}

String _tvScopeOptionId(
  TvAddResultScope scope, {
  required bool supportsSeasonScope,
}) {
  return switch (scope) {
    TvAddResultScope.media => tvAddMediaOptionId,
    TvAddResultScope.season =>
      supportsSeasonScope ? tvAddSeasonOptionId : tvAddMediaOptionId,
    TvAddResultScope.release => tvAddReleaseOptionId,
  };
}

String _tvProviderGroupTitle(ProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return candidate.title.trim();
}

bool tvAddProviderCandidateIsGroup(ProviderCandidate candidate) {
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
