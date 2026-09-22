import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/tv/provider/tv_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';

const tvAddMediaOptionId = 'tv.media';
const tvAddSeasonOptionId = 'tv.season';
const tvAddReleaseOptionId = 'tv.release';

enum TvAddResultScope { media, season, release }

typedef TvAddCoreScopeResolver = TvAddResultScope Function(
    CatalogSearchCandidate item);

typedef TvAddProviderScopeResolver = TvAddResultScope Function(
    TvProviderCandidate candidate);

LibraryAddResultPolicy buildTvAddResultPolicy({
  required String mediaLabel,
  required bool supportsSeasonScope,
  required TvAddCoreScopeResolver coreScopeForItem,
  required TvAddProviderScopeResolver providerScopeForCandidate,
  required String Function(CatalogSearchCandidate item) coreGroupTitleBuilder,
  required bool Function(TvProviderCandidate candidate)
      providerCandidateIsGroup,
  int Function(TvProviderCandidate left, TvProviderCandidate right)?
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
    typedProviderResultVisibility: (candidate, context) =>
        candidate is TvProviderCandidate &&
        context.optionIsEnabled(
          _tvScopeOptionId(
            providerScopeForCandidate(candidate),
            supportsSeasonScope: supportsSeasonScope,
          ),
        ),
    coreGroupTitleBuilder: coreGroupTitleBuilder,
    typedProviderGroupTitleBuilder: (candidate) =>
        candidate is TvProviderCandidate
            ? _tvProviderGroupTitle(candidate)
            : candidate.title,
    typedProviderCandidateIsGroup: (candidate) =>
        candidate is TvProviderCandidate && providerCandidateIsGroup(candidate),
    typedProviderCandidateComparator: (left, right) {
      if (left is TvProviderCandidate && right is TvProviderCandidate) {
        return providerCandidateComparator?.call(left, right) ??
            left.title.toLowerCase().compareTo(right.title.toLowerCase());
      }
      return left.title.toLowerCase().compareTo(right.title.toLowerCase());
    },
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

String _tvProviderGroupTitle(TvProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return candidate.title.trim();
}

bool tvAddProviderCandidateIsGroup(TvProviderCandidate candidate) {
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
