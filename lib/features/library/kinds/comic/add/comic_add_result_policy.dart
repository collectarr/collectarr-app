import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

const comicAddHideOwnedOptionId = 'comic.hide-owned';
const comicAddHideVariantsOptionId = 'comic.hide-variants';
const comicAddCompactIssuesOptionId = 'comic.compact-issues';

final comicAddResultPolicy = LibraryAddResultPolicy(
  options: const [
    LibraryAddResultOption(
      id: comicAddHideOwnedOptionId,
      label: 'Hide owned',
      initialValue: false,
    ),
    LibraryAddResultOption(
      id: comicAddHideVariantsOptionId,
      label: 'Hide variants',
      initialValue: false,
    ),
    LibraryAddResultOption(
      id: comicAddCompactIssuesOptionId,
      label: 'Compact issues',
      initialValue: false,
    ),
  ],
  coreResultVisibility: (item, context) {
    if (context.optionIsEnabled(comicAddHideOwnedOptionId) &&
        context.ownedCatalogRefs.contains(item.reference)) {
      return false;
    }
    if (context.optionIsEnabled(comicAddHideVariantsOptionId) &&
        _comicItemIsVariant(item)) {
      return false;
    }
    return true;
  },
);

bool _comicItemIsVariant(CatalogSearchCandidate item) {
  final metadata =
      item.kindCapability.mapTransport((transport) => transport).kindMetadata;
  return metadata is ComicCatalogItem && metadata.variant?.trim().isNotEmpty == true;
}
