import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';

/// Music presentation of the shared entry image store.
final class MusicAlbumImageRepository {
  const MusicAlbumImageRepository(this._db);
  final LocalDatabase _db;
  LibraryEntryRef _ref(String id) =>
      LibraryEntryRef(kind: CatalogMediaKind.music, id: LibraryEntryId(id));

  Future<List<MusicAlbumImage>> listForAlbum(String albumId) async {
    final images =
        await ItemImageRepository(_db).listForLibraryEntryRef(_ref(albumId));
    return [
      for (final image in images)
        MusicAlbumImage(
          id: image.id,
          albumId: albumId,
          purpose: image.imageType == 'front_cover' ||
                  image.imageType == 'back_cover'
              ? MusicAlbumImagePurpose.cover
              : MusicAlbumImagePurpose.personal,
          imageType: image.imageType.startsWith('personal:')
              ? image.imageType.substring(9)
              : image.imageType,
          imageData: image.imageData,
          description: image.caption,
          sortOrder: image.sortOrder,
          createdAt: image.createdAt,
        )
    ];
  }

  Future<void> upsert(MusicAlbumImage image) =>
      ItemImageRepository(_db).add(ItemImage(
        id: image.id,
        libraryEntryRef: _ref(image.albumId),
        imageType: image.purpose == MusicAlbumImagePurpose.cover
            ? image.imageType
            : 'personal:${image.imageType}',
        imageData: image.imageData,
        caption: image.description,
        sortOrder: image.sortOrder,
        createdAt: image.createdAt,
      ));

  Future<void> replaceForAlbum(
      String albumId, List<MusicAlbumImage> images) async {
    if (images.any((image) => image.albumId != albumId)) {
      throw StateError('Image batch belongs to another entry.');
    }
    if (images
            .where((image) => image.purpose == MusicAlbumImagePurpose.personal)
            .length >
        5) {
      throw StateError('Maximum five personal images.');
    }
    await _db.transaction(() async {
      await ItemImageRepository(_db).deleteAllForLibraryEntryRef(_ref(albumId));
      for (final image in images) {
        await upsert(image);
      }
    });
  }

  Future<void> delete(String id) => ItemImageRepository(_db).delete(id);
}
