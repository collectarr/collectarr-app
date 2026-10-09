import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
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
  LibraryEntryRef libraryEntryRef(String id) => LibraryEntryRef(
        kind: CatalogMediaKind.comic,
        id: LibraryEntryId(id),
      );

  ItemImage image(String id, String owner, {int sortOrder = 0}) => ItemImage(
        id: id,
        libraryEntryRef: libraryEntryRef(owner),
        imageData: bytes([sortOrder + 1]),
        sortOrder: sortOrder,
        createdAt: DateTime.utc(2026, 1, 1),
      );

  test('listForLibraryEntryRef returns empty initially', () async {
    expect(
        await repo.listForLibraryEntryRef(libraryEntryRef('entry-1')), isEmpty);
  });

  test('add inserts and retrieves image', () async {
    await repo.add(image('img-1', 'entry-1'));
    final images =
        await repo.listForLibraryEntryRef(libraryEntryRef('entry-1'));
    expect(images, hasLength(1));
    expect(images.single.id, 'img-1');
    expect(images.single.libraryEntryRef, libraryEntryRef('entry-1'));
    expect(images.single.imageData, orderedEquals([1]));
  });

  test('listForLibraryEntryRef returns images sorted by sortOrder', () async {
    await repo.add(image('img-2', 'entry-1', sortOrder: 2));
    await repo.add(image('img-1', 'entry-1'));
    await repo.add(image('img-3', 'entry-1', sortOrder: 1));

    final images =
        await repo.listForLibraryEntryRef(libraryEntryRef('entry-1'));
    expect(images.map((i) => i.id), ['img-1', 'img-3', 'img-2']);
  });

  test('updateCaption changes caption only', () async {
    await repo.add(
      image('img-1', 'entry-1').copyWith(caption: 'Original'),
    );
    await repo.updateCaption('img-1', 'Updated caption');
    final result =
        await repo.listForLibraryEntryRef(libraryEntryRef('entry-1'));
    expect(result.single.caption, 'Updated caption');
    expect(result.single.imageData, orderedEquals([1]));
  });

  test('updateCaption can set caption to null', () async {
    await repo.add(image('img-1', 'entry-1').copyWith(caption: 'Has caption'));
    await repo.updateCaption('img-1', null);
    final result =
        await repo.listForLibraryEntryRef(libraryEntryRef('entry-1'));
    expect(result.single.caption, isNull);
  });

  test('delete removes single image', () async {
    await repo.add(image('img-1', 'entry-1'));
    await repo.add(image('img-2', 'entry-1', sortOrder: 1));
    await repo.delete('img-1');
    final result =
        await repo.listForLibraryEntryRef(libraryEntryRef('entry-1'));
    expect(result, hasLength(1));
    expect(result.single.id, 'img-2');
  });

  test('deleteAllForLibraryEntryRef removes all images for one ref only',
      () async {
    await repo.add(image('img-1', 'entry-1'));
    await repo.add(image('img-2', 'entry-2'));
    await repo.deleteAllForLibraryEntryRef(libraryEntryRef('entry-1'));
    expect(
        await repo.listForLibraryEntryRef(libraryEntryRef('entry-1')), isEmpty);
    expect(await repo.listForLibraryEntryRef(libraryEntryRef('entry-2')),
        hasLength(1));
  });

  test('countForLibraryEntryRef returns correct count', () async {
    expect(await repo.countForLibraryEntryRef(libraryEntryRef('entry-1')), 0);
    await repo.add(image('img-1', 'entry-1'));
    await repo.add(image('img-2', 'entry-1', sortOrder: 1));
    expect(await repo.countForLibraryEntryRef(libraryEntryRef('entry-1')), 2);
  });

  test('different kinds with equal ids remain isolated', () async {
    final bookRef = LibraryEntryRef.fromKey('book:entry-1');
    await repo.add(image('img-comic', 'entry-1'));
    await repo.add(
      ItemImage(
        id: 'img-book',
        libraryEntryRef: bookRef,
        imageData: bytes([2]),
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    expect(await repo.listForLibraryEntryRef(libraryEntryRef('entry-1')),
        hasLength(1));
    expect(await repo.listForLibraryEntryRef(bookRef), hasLength(1));
    expect(
        await repo.listForLibraryEntryRef(libraryEntryRef('entry-3')), isEmpty);
  });
}
