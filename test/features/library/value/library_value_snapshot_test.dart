import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/value/library_value_snapshot.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combines provider, manual, purchase, sold, and insurance values', () {
    final entry = LibraryWorkspaceEntry(
      id: 'comic-1',
      mediaType: 'comic',
      title: 'Sample Comic',
      updatedAt: DateTime.utc(2026, 7, 5),
      marketValueCents: 2500,
      marketValueCurrency: 'USD',
    );
    final ownedItem = OwnedItem(
      id: 'owned-1',
      catalogRef: const CatalogEntityRef(
        kind: 'comic',
        entityType: CatalogEntityType.ownedCopy,
        id: 'comic-1',
      ),
      updatedAt: DateTime.utc(2026, 7, 5),
      pricePaidCents: 1200,
      sellPriceCents: 3200,
      marketValueCents: 1800,
      currency: 'USD',
    );

    final snapshot = LibraryValueSnapshot.fromEntry(
      entry,
      ownedItem: ownedItem,
      providerName: 'Comic provider',
    );

    expect(snapshot.providerValueCents, 2500);
    expect(snapshot.manualEstimatedValueCents, 1800);
    expect(snapshot.currentValueCents, 2500);
    expect(snapshot.insuranceValueCents, 2500);
    expect(snapshot.profitLossCents, 2000);
    expect(snapshot.history.map((entry) => entry.label), [
      'Purchase',
      'Comic provider',
      'Manual estimate',
      'Insurance',
      'Sold',
    ]);
  });
}
