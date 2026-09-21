import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/anime/provider/anime_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';

const animeAddMediaOptionId = 'anime.media';
const animeAddSeasonOptionId = 'anime.season';
const animeAddReleaseOptionId = 'anime.release';

enum AnimeAddResultScope { media, season, release }

typedef AnimeAddCoreScopeResolver = AnimeAddResultScope Function(
    CatalogSearchCandidate item);

typedef AnimeAddProviderScopeResolver = AnimeAddResultScope Function(
    AnimeProviderCandidate candidate);

LibraryAddResultPolicy buildAnimeAddResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required AnimeAddCoreScopeResolver coreScopeForItem,
  required AnimeAddProviderScopeResolver providerScopeForCandidate,
  required String Function(CatalogSearchCandidate item) coreGroupTitleBuilder,
  required bool Function(AnimeProviderCandidate candidate)
      providerCandidateIsGroup,
  int Function(AnimeProviderCandidate left, AnimeProviderCandidate right)?
      providerCandidateComparator,
}) {
  return LibraryAddResultPolicy(
    useGridResults: true,
    options: [
      LibraryAddResultOption(
        id: animeAddMediaOptionId,
        label: mediaLabel,
      ),
      if (supportsSeasonScope)
        const LibraryAddResultOption(
          id: animeAddSeasonOptionId,
          label: 'Seasons',
        ),
      const LibraryAddResultOption(
        id: animeAddReleaseOptionId,
        label: 'Releases',
      ),
    ],
    coreResultVisibility: (item, context) => context.optionIsEnabled(
      _animeScopeOptionId(
        coreScopeForItem(item),
        supportsSeasonScope: supportsSeasonScope,
      ),
    ),
    typedProviderResultVisibility: (candidate, context) =>
        candidate is AnimeProviderCandidate &&
        context.optionIsEnabled(
          _animeScopeOptionId(
            providerScopeForCandidate(candidate),
            supportsSeasonScope: supportsSeasonScope,
          ),
        ),
    coreGroupTitleBuilder: coreGroupTitleBuilder,
    typedProviderGroupTitleBuilder: (candidate) =>
        candidate is AnimeProviderCandidate
            ? _animeProviderGroupTitle(candidate)
            : candidate.title,
    typedProviderCandidateIsGroup: (candidate) =>
        candidate is AnimeProviderCandidate &&
        providerCandidateIsGroup(candidate),
    typedProviderCandidateComparator: (left, right) {
      if (left is AnimeProviderCandidate && right is AnimeProviderCandidate) {
        return providerCandidateComparator?.call(left, right) ??
            left.title.toLowerCase().compareTo(right.title.toLowerCase());
      }
      return left.title.toLowerCase().compareTo(right.title.toLowerCase());
    },
  );
}

String _animeScopeOptionId(
  AnimeAddResultScope scope, {
  required bool supportsSeasonScope,
}) {
  return switch (scope) {
    AnimeAddResultScope.media => animeAddMediaOptionId,
    AnimeAddResultScope.season =>
      supportsSeasonScope ? animeAddSeasonOptionId : animeAddMediaOptionId,
    AnimeAddResultScope.release => animeAddReleaseOptionId,
  };
}

String _animeProviderGroupTitle(AnimeProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return candidate.title.trim();
}

bool animeAddProviderCandidateIsGroup(AnimeProviderCandidate candidate) {
  if (candidate.searchRole.isWorkLike) return true;
  if (candidate.searchRole.isReleaseLike) return false;
  return (candidate.issueNumber?.trim().isEmpty ?? true) &&
      !candidate.isVariant;
}
