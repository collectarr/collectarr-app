import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_reading_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final updatedAt = DateTime.utc(2024, 5, 1, 12);
  final startedAt = DateTime.utc(2024, 4, 1);
  final item = ComicOwnedItem(
    id: const ComicOwnedItemId('owned-comic-1'),
    catalogRef: const CatalogEntityRef(
      kind: 'comic',
      entityType: CatalogEntityType.work,
      id: 'comic-1',
    ),
    createdAt: DateTime.utc(2024, 1, 1),
    isDigital: false,
    anchor: PersonalItemAnchor.fromRaw(
      anchorType: 'variant',
      editionId: 'release-1',
      variantId: 'variant-1',
    ),
    condition: 'Near Mint',
    grade: '9.8',
    purchaseDate: DateTime.utc(2024, 2, 10),
    pricePaidCents: 499,
    currency: 'USD',
    personalNotes: 'Signed at the convention',
    quantity: 1,
    indexNumber: 7,
    tags: 'key, signed',
    updatedAt: updatedAt,
    soldTo: null,
    ownerLabel: 'Alex',
    locationId: 'location-a',
    purchaseStore: 'Local shop',
    collectionStatus: 'owned',
    marketValueCents: 1250,
    details: const ComicOwnedDetails(
      rawOrSlabbed: 'Slabbed',
      gradingCompany: 'CGC',
      certificationNumber: 'CGC-123',
      keyComic: true,
      keyReason: 'First appearance',
      coverPriceCents: 10,
    ),
    reading: ComicReadingState(
      rating: 5,
      status: 'completed',
      startedAt: startedAt,
      finishedAt: DateTime.utc(2024, 4, 2),
    ),
  );

  test('typed Comic owned item round-trips all owned and reading state', () {
    final restored = ComicOwnedItem.fromJson(item.toJson());

    expect(restored, item);
    expect(restored.details.gradingCompany, 'CGC');
    expect(restored.details.keyComic, isTrue);
    expect(restored.reading.status, 'completed');
    expect(restored.reading.isFinished, isTrue);
  });

  test('legacy adapter keeps tracking outside Comic copy state', () {
    final legacy = OwnedItem<ComicOwnedDetails>(
      id: item.id.value,
      catalogRef: item.catalogRef,
      createdAt: item.createdAt,
      isDigital: item.isDigital,
      anchor: item.anchor,
      condition: item.condition,
      grade: item.grade,
      purchaseDate: item.purchaseDate,
      pricePaidCents: item.pricePaidCents,
      currency: item.currency,
      personalNotes: item.personalNotes,
      quantity: item.quantity,
      indexNumber: item.indexNumber,
      rating: item.reading.rating,
      readStatus: item.reading.status,
      startedAt: item.reading.startedAt,
      finishedAt: item.reading.finishedAt,
      tags: item.tags,
      updatedAt: item.updatedAt,
      ownerLabel: item.ownerLabel,
      locationId: item.locationId,
      purchaseStore: item.purchaseStore,
      collectionStatus: item.collectionStatus,
      marketValueCents: item.marketValueCents,
      details: item.details,
    );

    final typed = ComicOwnedItemProjection.fromOwnedItem(legacy);
    expect(typed, item);

    final roundTripped = ComicOwnedItemProjection.toOwnedItem(typed);
    expect(roundTripped.toJson(), legacy.toJson());
  });

  test('typed Comic owned item rejects another kind', () {
    expect(
      () => ComicOwnedItem.fromJson({
        ...item.toJson(),
        'catalog_ref': const CatalogEntityRef(
          kind: 'book',
          entityType: CatalogEntityType.work,
          id: 'book-1',
        ).toJson(),
      }),
      throwsFormatException,
    );
  });
}
