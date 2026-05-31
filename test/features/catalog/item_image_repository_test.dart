import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late ItemImageRepository repo;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repo = ItemImageRepository(db);
  });

  tearDown(() => db.close());

  Uint8List bytes(List<int> values) => Uint8List.fromList(values);

  test('listForItem returns empty initially', () async {
    expect(await repo.listForItem('owned-1'), isEmpty);
  });

  test('add inserts and retrieves image', () async {
    final image = ItemImage(
      id: 'img-1',
      ownedItemId: 'owned-1',
      imageData: bytes([1, 2, 3]),
      caption: 'Front cover',
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    await repo.add(image);
    final images = await repo.listForItem('owned-1');
    expect(images, hasLength(1));
    expect(images.single.id, 'img-1');
    expect(images.single.imageData, orderedEquals([1, 2, 3]));
    expect(images.single.caption, 'Front cover');
    expect(images.single.sortOrder, 0);
  });

  test('listForItem returns images sorted by sortOrder', () async {
    await repo.add(ItemImage(
      id: 'img-2',
      ownedItemId: 'owned-1',
      imageData: bytes([2]),
      sortOrder: 2,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.add(ItemImage(
      id: 'img-1',
      ownedItemId: 'owned-1',
      imageData: bytes([1]),
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.add(ItemImage(
      id: 'img-3',
      ownedItemId: 'owned-1',
      imageData: bytes([3]),
      sortOrder: 1,
      createdAt: DateTime.utc(2026, 1, 1),
    ));

    final images = await repo.listForItem('owned-1');
    expect(images.map((i) => i.id), ['img-1', 'img-3', 'img-2']);
  });

  test('updateCaption changes caption only', () async {
    await repo.add(ItemImage(
      id: 'img-1',
      ownedItemId: 'owned-1',
      imageData: bytes([1]),
      caption: 'Original',
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.updateCaption('img-1', 'Updated caption');
    final images = await repo.listForItem('owned-1');
    expect(images.single.caption, 'Updated caption');
    expect(images.single.imageData, orderedEquals([1]));
  });

  test('updateCaption can set caption to null', () async {
    await repo.add(ItemImage(
      id: 'img-1',
      ownedItemId: 'owned-1',
      imageData: bytes([1]),
      caption: 'Has caption',
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.updateCaption('img-1', null);
    final images = await repo.listForItem('owned-1');
    expect(images.single.caption, isNull);
  });

  test('delete removes single image', () async {
    await repo.add(ItemImage(
      id: 'img-1',
      ownedItemId: 'owned-1',
      imageData: bytes([1]),
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.add(ItemImage(
      id: 'img-2',
      ownedItemId: 'owned-1',
      imageData: bytes([2]),
      sortOrder: 1,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.delete('img-1');
    final images = await repo.listForItem('owned-1');
    expect(images, hasLength(1));
    expect(images.single.id, 'img-2');
  });

  test('deleteAllForItem removes all images for item only', () async {
    await repo.add(ItemImage(
      id: 'img-1',
      ownedItemId: 'owned-1',
      imageData: bytes([1]),
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.add(ItemImage(
      id: 'img-2',
      ownedItemId: 'owned-2',
      imageData: bytes([2]),
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.deleteAllForItem('owned-1');
    expect(await repo.listForItem('owned-1'), isEmpty);
    expect(await repo.listForItem('owned-2'), hasLength(1));
  });

  test('countForItem returns correct count', () async {
    expect(await repo.countForItem('owned-1'), 0);
    await repo.add(ItemImage(
      id: 'img-1',
      ownedItemId: 'owned-1',
      imageData: bytes([1]),
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.add(ItemImage(
      id: 'img-2',
      ownedItemId: 'owned-1',
      imageData: bytes([2]),
      sortOrder: 1,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    expect(await repo.countForItem('owned-1'), 2);
  });

  test('listForItem isolates by ownedItemId', () async {
    await repo.add(ItemImage(
      id: 'img-1',
      ownedItemId: 'owned-1',
      imageData: bytes([1]),
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    await repo.add(ItemImage(
      id: 'img-2',
      ownedItemId: 'owned-2',
      imageData: bytes([2]),
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
    ));
    expect(await repo.listForItem('owned-1'), hasLength(1));
    expect(await repo.listForItem('owned-2'), hasLength(1));
    expect(await repo.listForItem('owned-3'), isEmpty);
  });
}
