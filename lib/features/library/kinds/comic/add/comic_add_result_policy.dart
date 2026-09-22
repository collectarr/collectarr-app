import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_search_helpers.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/provider/comic_provider_candidates.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_role.dart';

const comicAddHideOwnedOptionId = 'comic.hide-owned';
const comicAddHideVariantsOptionId = 'comic.hide-variants';
const comicAddCompactIssuesOptionId = 'comic.compact-issues';

final comicAddResultPolicy = LibraryAddResultPolicy(
  options: const [
    LibraryAddResultOption(
      id: comicAddHideOwnedOptionId,
      label: 'Hide owned',
      initialValue: false,
      showInSourceToggles: false,
    ),
    LibraryAddResultOption(
      id: comicAddHideVariantsOptionId,
      label: 'Hide variants',
      initialValue: false,
      showInSourceToggles: false,
    ),
    LibraryAddResultOption(
      id: comicAddCompactIssuesOptionId,
      label: 'Compact issues',
      initialValue: false,
      showInSourceToggles: false,
    ),
  ],
  coreResultVisibility: (item, context) {
    if (context.optionIsEnabled(comicAddHideOwnedOptionId) &&
        context.ownedCatalogRefs.contains(item.catalogRef)) {
      return false;
    }
    if (context.optionIsEnabled(comicAddHideVariantsOptionId) &&
        _comicItemIsVariant(item)) {
      return false;
    }
    return true;
  },
  typedProviderResultVisibility: (candidate, context) {
    return candidate is! ComicProviderCandidate ||
        !(context.optionIsEnabled(comicAddHideVariantsOptionId) &&
            candidate.searchRole == ProviderSearchRole.variant);
  },
  coreGroupTitleBuilder: _comicGroupTitle,
  typedProviderGroupTitleBuilder: (candidate) =>
      candidate is ComicProviderCandidate
          ? _comicProviderGroupTitle(candidate)
          : candidate.title,
  typedProviderCandidateIsGroup: (candidate) =>
      candidate is ComicProviderCandidate &&
      _comicProviderCandidateIsGroup(candidate),
  typedProviderCandidateComparator: (left, right) =>
      left is ComicProviderCandidate && right is ComicProviderCandidate
          ? compareComicIssueCandidates(left, right)
          : left.title.toLowerCase().compareTo(right.title.toLowerCase()),
);

bool _comicItemIsVariant(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  return metadata is ComicMedia && metadata.variant?.trim().isNotEmpty == true;
}

String _comicGroupTitle(CatalogSearchCandidate item) {
  final metadata = item.mapTransport((transport) => transport).kindMetadata;
  if (metadata is ComicMedia) {
    final seriesTitle =
        metadata.seriesTitle?.trim() ?? metadata.series?.seriesTitle?.trim();
    if (seriesTitle != null && seriesTitle.isNotEmpty) {
      return seriesTitle;
    }
  }
  return item.primaryLabel;
}

String _comicProviderGroupTitle(ComicProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return candidate.title.trim();
}

bool _comicProviderCandidateIsGroup(ComicProviderCandidate candidate) {
  return switch (candidate.searchRole) {
    ProviderSearchRole.work ||
    ProviderSearchRole.releaseGroup ||
    ProviderSearchRole.series ||
    ProviderSearchRole.volume =>
      true,
    ProviderSearchRole.issue ||
    ProviderSearchRole.variant ||
    ProviderSearchRole.release ||
    ProviderSearchRole.edition ||
    ProviderSearchRole.season ||
    ProviderSearchRole.episode =>
      false,
  };
}
