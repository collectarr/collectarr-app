import 'package:collectarr_app/features/library/add/contracts/library_add_result_policy.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_result_policy.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Comic Add policy owns entry and variant visibility', () {
    final entry = CatalogSearchCandidate.fromItem(testCatalogItemFromJson({
      'id': 'comic-entry',
      'kind': 'comic',
      'title': 'Entry Comic',
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
        comicAddHideEntryOptionId: true,
        comicAddHideVariantsOptionId: true,
      },
    );
    final visible = comicAddResultPolicy.filterCoreResults(
      items: [entry, variant, regular],
      state: state,
      entryCatalogRefs: {
        CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'comic-entry',
        ),
      },
    );
    expect(visible.map((item) => item.reference.id), ['comic-regular']);
  });
}
