import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/movie/provider/movie_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';

const movieAddMediaOptionId = 'movie.media';
const movieAddSeasonOptionId = 'movie.season';
const movieAddReleaseOptionId = 'movie.release';

enum MovieAddResultScope { media, season, release }

typedef MovieAddCoreScopeResolver = MovieAddResultScope Function(
    CatalogSearchCandidate item);

typedef MovieAddProviderScopeResolver = MovieAddResultScope Function(
    MovieProviderCandidate candidate);

LibraryAddResultPolicy buildMovieAddResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required MovieAddCoreScopeResolver coreScopeForItem,
  required MovieAddProviderScopeResolver providerScopeForCandidate,
  required String Function(CatalogSearchCandidate item) coreGroupTitleBuilder,
  required bool Function(MovieProviderCandidate candidate)
      providerCandidateIsGroup,
  int Function(MovieProviderCandidate left, MovieProviderCandidate right)?
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
    typedProviderResultVisibility: (candidate, context) =>
        candidate is MovieProviderCandidate &&
        context.optionIsEnabled(
          _movieScopeOptionId(
            providerScopeForCandidate(candidate),
            supportsSeasonScope: supportsSeasonScope,
          ),
        ),
    coreGroupTitleBuilder: coreGroupTitleBuilder,
    typedProviderGroupTitleBuilder: (candidate) =>
        candidate is MovieProviderCandidate
            ? _movieProviderGroupTitle(candidate)
            : candidate.title,
    typedProviderCandidateIsGroup: (candidate) =>
        candidate is MovieProviderCandidate &&
        providerCandidateIsGroup(candidate),
    typedProviderCandidateComparator: (left, right) {
      if (left is MovieProviderCandidate && right is MovieProviderCandidate) {
        return providerCandidateComparator?.call(left, right) ??
            left.title.toLowerCase().compareTo(right.title.toLowerCase());
      }
      return left.title.toLowerCase().compareTo(right.title.toLowerCase());
    },
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

String _movieProviderGroupTitle(MovieProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return candidate.title.trim();
}

bool movieAddProviderCandidateIsGroup(MovieProviderCandidate candidate) {
  return switch (candidate.searchRole) {
    ProviderSearchRole.work ||
    ProviderSearchRole.releaseGroup ||
    ProviderSearchRole.series =>
      true,
    ProviderSearchRole.release ||
    ProviderSearchRole.variant ||
    ProviderSearchRole.edition ||
    ProviderSearchRole.season ||
    ProviderSearchRole.episode ||
    ProviderSearchRole.issue ||
    ProviderSearchRole.volume =>
      false,
  };
}
