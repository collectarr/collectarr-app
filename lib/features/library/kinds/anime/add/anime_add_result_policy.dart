import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_candidate.dart';

const animeAddMediaOptionId = 'anime.media';
const animeAddSeasonOptionId = 'anime.season';
const animeAddReleaseOptionId = 'anime.release';

enum AnimeAddResultScope { media, season, release }

typedef AnimeAddCoreScopeResolver = AnimeAddResultScope Function(
    CatalogSearchCandidate item);

typedef AnimeAddProviderScopeResolver = AnimeAddResultScope Function(
    ProviderCandidate candidate);

LibraryAddResultPolicy buildAnimeAddResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required AnimeAddCoreScopeResolver coreScopeForItem,
  required AnimeAddProviderScopeResolver providerScopeForCandidate,
  required String Function(CatalogSearchCandidate item) coreGroupTitleBuilder,
  required bool Function(ProviderCandidate candidate) providerCandidateIsGroup,
  int Function(ProviderCandidate left, ProviderCandidate right)?
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
    providerResultVisibility: (candidate, context) => context.optionIsEnabled(
      _animeScopeOptionId(
        providerScopeForCandidate(candidate),
        supportsSeasonScope: supportsSeasonScope,
      ),
    ),
    coreGroupTitleBuilder: coreGroupTitleBuilder,
    providerGroupTitleBuilder: _animeProviderGroupTitle,
    providerCandidateIsGroup: providerCandidateIsGroup,
    providerCandidateComparator: providerCandidateComparator,
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

String _animeProviderGroupTitle(ProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return candidate.title.trim();
}

bool animeAddProviderCandidateIsGroup(ProviderCandidate candidate) {
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
