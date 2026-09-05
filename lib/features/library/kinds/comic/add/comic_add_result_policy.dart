import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_search_helpers.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

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
        context.ownedCatalogItemIds.contains(item.id)) {
      return false;
    }
    if (context.optionIsEnabled(comicAddHideVariantsOptionId) &&
        _comicItemIsVariant(item)) {
      return false;
    }
    return true;
  },
  providerResultVisibility: (candidate, context) {
    return !(context.optionIsEnabled(comicAddHideVariantsOptionId) &&
        candidate.isVariant);
  },
  coreGroupTitleBuilder: _comicGroupTitle,
  providerGroupTitleBuilder: _comicProviderGroupTitle,
  providerCandidateIsGroup: _comicProviderCandidateIsGroup,
  providerCandidateComparator: compareComicIssueCandidates,
);

bool _comicItemIsVariant(CatalogItem item) {
  final metadata = item.kindMetadata;
  return metadata is ComicMedia && metadata.variant?.trim().isNotEmpty == true;
}

String _comicGroupTitle(CatalogItem item) {
  final metadata = item.kindMetadata;
  if (metadata is ComicMedia) {
    final seriesTitle =
        metadata.seriesTitle?.trim() ?? metadata.series?.seriesTitle?.trim();
    if (seriesTitle != null && seriesTitle.isNotEmpty) {
      return seriesTitle;
    }
  }
  return item.title;
}

String _comicProviderGroupTitle(ProviderCandidate candidate) {
  final seriesTitle = candidate.series?.seriesTitle?.trim();
  if (seriesTitle != null && seriesTitle.isNotEmpty) {
    return seriesTitle;
  }
  return candidate.title.trim();
}

bool _comicProviderCandidateIsGroup(ProviderCandidate candidate) {
  if (candidate.candidateType == 'series') return true;
  if (candidate.candidateType == 'issue' || candidate.isVariant) return false;
  return candidate.issueNumber?.trim().isEmpty ?? true;
}
