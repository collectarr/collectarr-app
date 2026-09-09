import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
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
  OwnedItemRef ownedRef(String id) => OwnedItemRef(
        kind: CatalogMediaKind.comic,
        id: OwnedItemId(id),
      );

  ItemImage image(String id, String owner, {int sortOrder = 0}) => ItemImage(
        id: id,
        ownedRef: ownedRef(owner),
        imageData: bytes([sortOrder + 1]),
        sortOrder: sortOrder,
        createdAt: DateTime.utc(2026, 1, 1),
      );

  test('listForOwnedRef returns empty initially', () async {
    expect(await repo.listForOwnedRef(ownedRef('owned-1')), isEmpty);
  });

  test('add inserts and retrieves image', () async {
    await repo.add(image('img-1', 'owned-1'));
    final images = await repo.listForOwnedRef(ownedRef('owned-1'));
    expect(images, hasLength(1));
    expect(images.single.id, 'img-1');
    expect(images.single.ownedRef, ownedRef('owned-1'));
    expect(images.single.imageData, orderedEquals([1]));
  });

  test('listForOwnedRef returns images sorted by sortOrder', () async {
    await repo.add(image('img-2', 'owned-1', sortOrder: 2));
    await repo.add(image('img-1', 'owned-1'));
    await repo.add(image('img-3', 'owned-1', sortOrder: 1));

    final images = await repo.listForOwnedRef(ownedRef('owned-1'));
    expect(images.map((i) => i.id), ['img-1', 'img-3', 'img-2']);
  });

  test('updateCaption changes caption only', () async {
    await repo.add(
      image('img-1', 'owned-1').copyWith(caption: 'Original'),
    );
    await repo.updateCaption('img-1', 'Updated caption');
    final result = await repo.listForOwnedRef(ownedRef('owned-1'));
    expect(result.single.caption, 'Updated caption');
    expect(result.single.imageData, orderedEquals([1]));
  });

  test('updateCaption can set caption to null', () async {
    await repo.add(image('img-1', 'owned-1').copyWith(caption: 'Has caption'));
    await repo.updateCaption('img-1', null);
    final result = await repo.listForOwnedRef(ownedRef('owned-1'));
    expect(result.single.caption, isNull);
  });

  test('delete removes single image', () async {
    await repo.add(image('img-1', 'owned-1'));
    await repo.add(image('img-2', 'owned-1', sortOrder: 1));
    await repo.delete('img-1');
    final result = await repo.listForOwnedRef(ownedRef('owned-1'));
    expect(result, hasLength(1));
    expect(result.single.id, 'img-2');
  });

  test('deleteAllForOwnedRef removes all images for one ref only', () async {
    await repo.add(image('img-1', 'owned-1'));
    await repo.add(image('img-2', 'owned-2'));
    await repo.deleteAllForOwnedRef(ownedRef('owned-1'));
    expect(await repo.listForOwnedRef(ownedRef('owned-1')), isEmpty);
    expect(await repo.listForOwnedRef(ownedRef('owned-2')), hasLength(1));
  });

  test('countForOwnedRef returns correct count', () async {
    expect(await repo.countForOwnedRef(ownedRef('owned-1')), 0);
    await repo.add(image('img-1', 'owned-1'));
    await repo.add(image('img-2', 'owned-1', sortOrder: 1));
    expect(await repo.countForOwnedRef(ownedRef('owned-1')), 2);
  });

  test('different kinds with equal ids remain isolated', () async {
    final bookRef = OwnedItemRef.fromKey('book:owned-1');
    await repo.add(image('img-comic', 'owned-1'));
    await repo.add(
      ItemImage(
        id: 'img-book',
        ownedRef: bookRef,
        imageData: bytes([2]),
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    expect(await repo.listForOwnedRef(ownedRef('owned-1')), hasLength(1));
    expect(await repo.listForOwnedRef(bookRef), hasLength(1));
    expect(await repo.listForOwnedRef(ownedRef('owned-3')), isEmpty);
  });
}
