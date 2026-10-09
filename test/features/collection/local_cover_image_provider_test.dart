import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/collection/repositories/item_images_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a missing cached cover updates on insert, replacement and deletion',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWithValue(db)]);
    final entry = LibraryEntryRef(
        kind: CatalogMediaKind.music, id: const LibraryEntryId('album'));
    final provider = localItemImageProvider(
        (libraryEntryRef: entry, imageType: 'front_cover'));
    final changes = <List<int>?>[];
    final subscription = container.listen(provider, (_, next) {
      if (next.hasValue) changes.add(next.value);
    });
    Future<void> waitForBytes(List<int>? expected) async {
      final done = Completer<void>();
      final listener = container.listen(provider, (_, next) {
        if (next.hasValue &&
            listEquals(next.value, expected) &&
            !done.isCompleted) {
          done.complete();
        }
      }, fireImmediately: true);
      try {
        await done.future.timeout(const Duration(seconds: 5));
      } finally {
        listener.close();
      }
    }

    try {
      expect(await container.read(provider.future), isNull);
      final repo = ItemImagesCacheRepository(db);
      await repo.upsert(
          id: 'front',
          libraryEntryRef: entry,
          imageType: 'front_cover',
          imageData: Uint8List.fromList([1, 2]));
      await waitForBytes([1, 2]);
      expect(container.read(provider).value, [1, 2]);
      await repo.upsert(
          id: 'front',
          libraryEntryRef: entry,
          imageType: 'front_cover',
          imageData: Uint8List.fromList([3, 4]));
      await waitForBytes([3, 4]);
      expect(container.read(provider).value, [3, 4]);
      final book = LibraryEntryRef(
          kind: CatalogMediaKind.book, id: const LibraryEntryId('album'));
      await repo.upsert(
          id: 'book-back',
          libraryEntryRef: book,
          imageType: 'back_cover',
          imageData: Uint8List.fromList([5]));
      final summaries =
          await ItemImageRepository(db).typesForLibraryEntryRefs([entry, book]);
      expect(summaries[entry], {'front_cover'});
      expect(summaries[book], {'back_cover'});
      expect(
          await ItemImageRepository(db).typesForLibraryEntryRefs([]), isEmpty);
      await repo.deleteById('front');
      await waitForBytes(null);
      expect(container.read(provider).value, isNull);
      expect(
          changes,
          containsAllInOrder([
            null,
            [1, 2],
            [3, 4],
            null
          ]));
    } finally {
      subscription.close();
      container.dispose();
      await db.close();
    }
  });
}
