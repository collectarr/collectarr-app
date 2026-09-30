import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:drift/drift.dart';

final class MusicAlbumImageRepository {
  const MusicAlbumImageRepository(this._db);

  final LocalDatabase _db;

  Future<List<MusicAlbumImage>> listForAlbum(String albumId) async {
    _requireAlbumId(albumId);
    final rows = await (_db.select(_db.musicAlbumImagesRows)
          ..where((row) => row.albumId.equals(albumId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.purpose),
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
    return [
      for (final row in rows)
        MusicAlbumImage(
          id: row.id,
          albumId: row.albumId,
          purpose: MusicAlbumImagePurpose.values.firstWhere(
            (purpose) => purpose.storageValue == row.purpose,
          ),
          imageType: row.imageType,
          imageData: row.imageData,
          description: row.description,
          sortOrder: row.sortOrder,
          createdAt: row.createdAt,
        ),
    ];
  }

  Future<void> upsert(MusicAlbumImage image) {
    _requireAlbumId(image.albumId);
    return _db.into(_db.musicAlbumImagesRows).insertOnConflictUpdate(
          MusicAlbumImagesRowsCompanion.insert(
            id: image.id,
            albumId: image.albumId,
            purpose: image.purpose.storageValue,
            imageType: image.imageType,
            imageData: image.imageData,
            description: Value(image.description),
            sortOrder: Value(image.sortOrder),
            createdAt: image.createdAt,
          ),
        );
  }

  Future<void> replaceForAlbum(
    String albumId,
    List<MusicAlbumImage> images,
  ) async {
    _requireAlbumId(albumId);
    if (images.any((image) => image.albumId != albumId)) {
      throw StateError('Album image batch contains a different album id.');
    }
    if (images
            .where((image) => image.purpose == MusicAlbumImagePurpose.personal)
            .length >
        5) {
      throw StateError(
          'A Music album can have at most five personal images.');
    }
    await _db.transaction(() async {
      await (_db.delete(_db.musicAlbumImagesRows)
            ..where((row) => row.albumId.equals(albumId)))
          .go();
      if (images.isEmpty) return;
      await _db.batch((batch) {
        batch.insertAll(
          _db.musicAlbumImagesRows,
          images.map(
            (image) => MusicAlbumImagesRowsCompanion.insert(
              id: image.id,
              albumId: image.albumId,
              purpose: image.purpose.storageValue,
              imageType: image.imageType,
              imageData: image.imageData,
              description: Value(image.description),
              sortOrder: Value(image.sortOrder),
              createdAt: image.createdAt,
            ),
          ),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> delete(String id) async {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    await (_db.delete(_db.musicAlbumImagesRows)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  static void _requireAlbumId(String albumId) {
    if (albumId.trim().isEmpty) {
      throw ArgumentError.value(albumId, 'albumId');
    }
  }
}
