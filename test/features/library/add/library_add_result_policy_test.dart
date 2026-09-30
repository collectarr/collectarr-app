import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_result_policy.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Comic Add policy owns owned and variant visibility', () {
    final owned = CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'comic-owned',
      'kind': 'comic',
      'title': 'Owned Comic',
    }));
    final variant = CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'comic-variant',
      'kind': 'comic',
      'title': 'Variant Comic',
      'variant': 'Foil',
    }));
    final regular = CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'comic-regular',
      'kind': 'comic',
      'title': 'Regular Comic',
    }));

    final state = const LibraryAddResultPolicyState(
      values: {
        comicAddHideOwnedOptionId: true,
        comicAddHideVariantsOptionId: true,
      },
    );
    final visible = comicAddResultPolicy.filterCoreResults(
      items: [owned, variant, regular],
      state: state,
      ownedCatalogRefs: {
        CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: const CatalogEntityTypeId('work'),
          id: 'comic-owned',
        ),
      },
    );
    expect(visible.map((item) => item.reference.id), ['comic-regular']);
  });
}
