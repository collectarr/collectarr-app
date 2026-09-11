import 'package:collectarr_app/core/api/dto/catalog/catalog_publishing_details_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/test/helpers/test_owned_details.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_projector.dart';
import 'package:collectarr_app/features/library/value/library_value_snapshot.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_factories.dart';

void main() {
  test('combines provider, manual, purchase, sold, and insurance values', () {
    final ownedItem = testOwnedItem(
      id: 'owned-1',
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: const CatalogEntityTypeId('owned_copy'),
        id: 'comic-1',
      ),
      updatedAt: DateTime.utc(2026, 7, 5),
      pricePaidCents: 1200,
      sellPriceCents: 3200,
      marketValueCents: 1800,
      currency: 'USD',
    );
    final source = LibraryWorkspaceSource(
      itemId: 'comic-1',
      catalogTransport: testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Sample Comic',
        publishing: const CatalogPublishingDetailsDto(
          coverPriceCents: 2500,
        ),
      ).asShelfCatalogItem,
      ownedSummary: testOwnedSummary(ownedItem),
    );
    const node = LibraryTitleNodeRef(titleItemId: 'comic-1');
    final dto = const ComicWorkspaceProjector().projectTitle(
      source: source,
      node: node,
    );
    final item = LibraryProjectionItem(
      source: source,
      node: node,
      dto: dto,
    );

    final snapshot = LibraryValueSnapshot.fromItem(
      item,
      purchasePriceCents: ownedItem.pricePaidCents,
      soldPriceCents: ownedItem.sellPriceCents,
      manualEstimatedValueCents: ownedItem.marketValueCents,
      ownedCurrency: ownedItem.currency,
      providerName: 'Comic provider',
    );

    expect(snapshot.providerValueCents, 2500);
    expect(snapshot.manualEstimatedValueCents, 1800);
    expect(snapshot.displayPrimaryValueCents, 2500);
    expect(snapshot.insuranceValueCents, 2500);
    expect(snapshot.unrealizedGainLossCents, 1300);
    expect(snapshot.historyEntries.map((entry) => entry.label), [
      'Purchase price',
      'Manual estimate',
      'Comic provider',
      'Sold price',
    ]);
  });
}
