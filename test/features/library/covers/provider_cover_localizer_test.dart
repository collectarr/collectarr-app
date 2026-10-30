import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/library/covers/provider_cover_localizer.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

const _core = 'https://core.example.test';

Uint8List _jpeg(int width, int height) =>
    img.encodeJpg(img.Image(width: width, height: height), quality: 80);

ComicLibraryEntry _comic(String id, String? cover) => ComicLibraryEntry(
      id: LibraryEntryId(id),
      metadata: ComicCatalogItem(
        id: CatalogItemRef(kind: CatalogMediaKind.comic, id: id),
        title: id,
        coverImageUrl: cover,
        thumbnailImageUrl: cover,
      ),
      personal: const ComicPersonalData(),
      updatedAt: DateTime.utc(2026),
    );

LibraryEntryRef _ref(String id) =>
    LibraryEntryRef(kind: CatalogMediaKind.comic, id: LibraryEntryId(id));

void main() {
  test('Core images stay links; other http images are provider images', () {
    expect(isProviderImageUrl('$_core/images/a.webp', _core), isFalse);
    expect(
        isProviderImageUrl('https://clzcomics.r.sizr.io/a.jpg', _core), isTrue);
    expect(isProviderImageUrl('https://core.example.test:8443/a.jpg', _core),
        isTrue);
    expect(isProviderImageUrl('file:///covers/a.jpg', _core), isFalse);
  });

  test('wide covers are scaled down; narrow ones keep their bytes', () {
    final narrow = _jpeg(420, 630);
    expect(normalizeProviderCover(narrow), same(narrow));
    final wide = img.decodeImage(normalizeProviderCover(_jpeg(1200, 1800)))!;
    expect((wide.width, wide.height), (kProviderCoverMaxWidth, 900));
    expect(() => normalizeProviderCover(Uint8List.fromList([1, 2, 3])),
        throwsFormatException);
  });

  test('provider covers become local front covers and leave their links',
      () async {
    SharedPreferences.setMockInitialValues({});
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    await ComicEntryRepository(db).upsertAll([
      _comic('clz', 'https://clzcomics.r.sizr.io/core/covers/lg/1.jpg'),
      _comic('core', '$_core/images/download?object_key=2'),
      _comic('broken', 'https://clzcomics.r.sizr.io/missing.jpg'),
      _comic('local', 'https://clzcomics.r.sizr.io/3.jpg'),
      _comic('none', null),
    ]);
    await ItemImageRepository(db).add(ItemImage(
      id: 'chosen',
      libraryEntryRef: _ref('local'),
      imageType: 'front_cover',
      imageData: _jpeg(10, 15),
      createdAt: DateTime.utc(2026),
    ));
    final cover = _jpeg(420, 630);
    final requested = <String>[];
    final localizer = ProviderCoverLocalizer(
      database: db,
      mutations: container.read(libraryEntryMutationsProvider),
      coreBaseUrl: _core,
      fetch: (url) async {
        requested.add(url.toString());
        return url.path.contains('missing') ? null : cover;
      },
      normalize: (bytes) async => normalizeProviderCover(bytes),
    );

    final pending = await localizer.pendingEntries(CatalogMediaKind.comic);
    expect(pending.map((ref) => ref.id.value).toSet(), {'clz', 'broken'});

    final result = await localizer.localize(pending);
    expect(result, (done: 2, stored: 1, total: 2));
    expect(requested, hasLength(2));

    final store = LibraryEntryStore(db);
    final clz = await store.find(CatalogMediaKind.comic, 'clz');
    expect(clz!.catalogData.containsKey('cover_image_url'), isFalse);
    expect(clz.catalogData.containsKey('thumbnail_image_url'), isFalse);
    final images =
        await ItemImageRepository(db).listForLibraryEntryRef(_ref('clz'));
    expect(images.single.imageType, 'front_cover');
    expect(images.single.imageData, cover);

    final broken = await store.find(CatalogMediaKind.comic, 'broken');
    expect(broken!.catalogData['cover_image_url'], isNotNull);
    final core = await store.find(CatalogMediaKind.comic, 'core');
    expect(core!.catalogData['cover_image_url'], startsWith(_core));

    expect(await container.read(syncQueueRepositoryProvider).pendingCount(), 1);
    expect(await localizer.pendingEntries(CatalogMediaKind.comic),
        [_ref('broken')]);
  });
}
