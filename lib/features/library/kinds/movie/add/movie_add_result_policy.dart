import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';

const movieAddMediaOptionId = 'movie.media';
const movieAddSeasonOptionId = 'movie.season';
const movieAddReleaseOptionId = 'movie.release';

enum MovieAddResultScope { media, season, release }

typedef MovieAddCoreScopeResolver = MovieAddResultScope Function(
    CatalogSearchCandidate item);

typedef MovieAddProviderScopeResolver = MovieAddResultScope Function(
    ProviderCandidate candidate);

LibraryAddResultPolicy buildMovieAddResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required MovieAddCoreScopeResolver coreScopeForItem,
  required MovieAddProviderScopeResolver providerScopeForCandidate,
  required String Function(CatalogSearchCandidate item) coreGroupTitleBuilder,
  required bool Function(ProviderCandidate candidate) providerCandidateIsGroup,
  int Function(ProviderCandidate left, ProviderCandidate right)?
      providerCandidateComparator,
}) {
  return LibraryAddResultPolicy(
    useGridResults: true,
    options: [
      LibraryAddResultOption(
        id: movieAddMediaOptionId,
        label: mediaLabel,
      ),
      if (supportsSeasonScope)
        const LibraryAddResultOption(
          id: movieAddSeasonOptionId,
          label: 'Seasons',
        ),
      const LibraryAddResultOption(
        id: movieAddReleaseOptionId,
        label: 'Releases',
      ),
    ],
    coreResultVisibility: (item, context) => context.optionIsEnabled(
      _movieScopeOptionId(
        coreScopeForItem(item),
        supportsSeasonScope: supportsSeasonScope,
      ),
    ),
    providerResultVisibility: (candidate, context) => context.optionIsEnabled(
      _movieScopeOptionId(
        providerScopeForCandidate(candidate),
        supportsSeasonScope: supportsSeasonScope,
      ),
    ),
    coreGroupTitleBuilder: coreGroupTitleBuilder,
    providerGroupTitleBuilder: _movieProviderGroupTitle,
    providerCandidateIsGroup: providerCandidateIsGroup,
    providerCandidateComparator: providerCandidateComparator,
  );
}

String _movieScopeOptionId(
  MovieAddResultScope scope, {
  required bool supportsSeasonScope,
}) {
  return switch (scope) {
    MovieAddResultScope.media => movieAddMediaOptionId,
    MovieAddResultScope.season =>
      supportsSeasonScope ? movieAddSeasonOptionId : movieAddMediaOptionId,
    MovieAddResultScope.release => movieAddReleaseOptionId,
  };
}

String _movieProviderGroupTitle(ProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return candidate.title.trim();
}

bool movieAddProviderCandidateIsGroup(ProviderCandidate candidate) {
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
