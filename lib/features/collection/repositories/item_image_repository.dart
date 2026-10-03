import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:drift/drift.dart';

class ItemImageRepository {
  const ItemImageRepository(this._db);

  static const _refQueryChunkSize = 400;

  final LocalDatabase _db;

  Future<List<ItemImage>> listForLibraryEntryRef(LibraryEntryRef libraryEntryRef) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    final rows = await (_db.select(_db.itemImagesCache)
          ..where((row) => row.libraryEntryRefKey.equals(libraryEntryRef.key))
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<Map<LibraryEntryRef, List<ItemImage>>> listForLibraryEntryRefs(
    Iterable<LibraryEntryRef> libraryEntryRefs,
  ) async {
    final refs = libraryEntryRefs.toSet().toList(growable: false);
    for (final ref in refs) {
      requireKnownLibraryEntryRef(ref);
    }
    if (refs.isEmpty) {
      return const <LibraryEntryRef, List<ItemImage>>{};
    }
    final keys = refs.map((ref) => ref.key).toList(growable: false);
    final rows = <ItemImagesCacheData>[];
    for (var start = 0; start < keys.length; start += _refQueryChunkSize) {
      final end =
          (start + _refQueryChunkSize).clamp(0, keys.length).toInt();
      rows.addAll(
        await (_db.select(_db.itemImagesCache)
              ..where((row) => row.libraryEntryRefKey.isIn(
                    keys.sublist(start, end),
                  ))
              ..orderBy([
                (row) => OrderingTerm.asc(row.sortOrder),
                (row) => OrderingTerm.asc(row.createdAt),
              ]))
            .get(),
      );
    }
    final grouped = <LibraryEntryRef, List<ItemImage>>{};
    for (final row in rows) {
      final ref = LibraryEntryRef.fromKey(row.libraryEntryRefKey);
      grouped.putIfAbsent(ref, () => <ItemImage>[]).add(_fromRow(row));
    }
    return grouped;
  }

  Future<void> add(ItemImage image) {
    requireKnownLibraryEntryRef(image.libraryEntryRef);
    return _db.into(_db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: image.id,
            libraryEntryRefKey: image.libraryEntryRef.key,
            imageType: Value(image.imageType),
            imageData: image.imageData,
            caption: Value(image.caption),
            sortOrder: Value(image.sortOrder),
            createdAt: image.createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  static const Object _unset = Object();

  Future<void> updateMetadata(
    String id, {
    Object? caption = _unset,
    String? imageType,
    int? sortOrder,
  }) async {
    await (_db.update(_db.itemImagesCache)..where((row) => row.id.equals(id)))
        .write(
      ItemImagesCacheCompanion(
        caption: identical(caption, _unset)
            ? const Value.absent()
            : Value(caption as String?),
        imageType: imageType == null ? const Value.absent() : Value(imageType),
        sortOrder: sortOrder == null ? const Value.absent() : Value(sortOrder),
      ),
    );
  }

  Future<void> updateCaption(String id, String? caption) {
    return updateMetadata(id, caption: caption);
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.itemImagesCache)..where((row) => row.id.equals(id)))
        .go();
  }

  Future<void> deleteAllForLibraryEntryRef(LibraryEntryRef libraryEntryRef) {
    requireKnownLibraryEntryRef(libraryEntryRef);
    return (_db.delete(_db.itemImagesCache)
          ..where((row) => row.libraryEntryRefKey.equals(libraryEntryRef.key)))
        .go();
  }

  Future<int> countForLibraryEntryRef(LibraryEntryRef libraryEntryRef) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    final count = _db.itemImagesCache.id.count();
    final query = _db.selectOnly(_db.itemImagesCache)
      ..addColumns([count])
      ..where(_db.itemImagesCache.libraryEntryRefKey.equals(libraryEntryRef.key));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  ItemImage _fromRow(ItemImagesCacheData row) {
    return ItemImage(
      id: row.id,
      libraryEntryRef: LibraryEntryRef.fromKey(row.libraryEntryRefKey),
      imageType: row.imageType,
      imageData: row.imageData,
      caption: row.caption,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
    );
  }
}
