import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';

const comicAddHideEntryOptionId = 'comic.hide-entry';
const comicAddHideVariantsOptionId = 'comic.hide-variants';

final comicAddResultPolicy = LibraryAddResultPolicy(
  options: const [
    LibraryAddResultOption(
      id: comicAddHideEntryOptionId,
      label: 'Hide entry',
      initialValue: false,
    ),
    LibraryAddResultOption(
      id: comicAddHideVariantsOptionId,
      label: 'Hide variants',
      initialValue: false,
    ),
  ],
  coreResultVisibility: (item, context) {
    if (context.optionIsEnabled(comicAddHideEntryOptionId) &&
        context.entryCatalogRefs.contains(item.reference)) {
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
  final metadata = item.kindCapability.mapTransport(
      (transport) => ComicCatalogItem.fromJson(transport.kindData));
  return metadata.variant?.trim().isNotEmpty == true;
}
