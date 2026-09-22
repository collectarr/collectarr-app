import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_image.dart';
import 'package:drift/drift.dart';

final class MusicReleaseImageRepository {
  const MusicReleaseImageRepository(this._db);

  final LocalDatabase _db;

  Future<List<MusicReleaseImage>> listForRelease(String releaseId) async {
    _requireReleaseId(releaseId);
    final rows = await (_db.select(_db.musicReleaseImagesRows)
          ..where((row) => row.releaseId.equals(releaseId))
          ..orderBy([
            (row) => OrderingTerm.asc(row.purpose),
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
    return [
      for (final row in rows)
        MusicReleaseImage(
          id: row.id,
          releaseId: row.releaseId,
          purpose: MusicReleaseImagePurpose.values.firstWhere(
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

  Future<void> upsert(MusicReleaseImage image) {
    _requireReleaseId(image.releaseId);
    return _db.into(_db.musicReleaseImagesRows).insertOnConflictUpdate(
          MusicReleaseImagesRowsCompanion.insert(
            id: image.id,
            releaseId: image.releaseId,
            purpose: image.purpose.storageValue,
            imageType: image.imageType,
            imageData: image.imageData,
            description: Value(image.description),
            sortOrder: Value(image.sortOrder),
            createdAt: image.createdAt,
          ),
        );
  }

  Future<void> replaceForRelease(
    String releaseId,
    List<MusicReleaseImage> images,
  ) async {
    _requireReleaseId(releaseId);
    if (images.any((image) => image.releaseId != releaseId)) {
      throw StateError('Release image batch contains a different release id.');
    }
    if (images
            .where(
                (image) => image.purpose == MusicReleaseImagePurpose.personal)
            .length >
        5) {
      throw StateError(
          'A Music release can have at most five personal images.');
    }
    await _db.transaction(() async {
      await (_db.delete(_db.musicReleaseImagesRows)
            ..where((row) => row.releaseId.equals(releaseId)))
          .go();
      if (images.isEmpty) return;
      await _db.batch((batch) {
        batch.insertAll(
          _db.musicReleaseImagesRows,
          images.map(
            (image) => MusicReleaseImagesRowsCompanion.insert(
              id: image.id,
              releaseId: image.releaseId,
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
    await (_db.delete(_db.musicReleaseImagesRows)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  static void _requireReleaseId(String releaseId) {
    if (releaseId.trim().isEmpty) {
      throw ArgumentError.value(releaseId, 'releaseId');
    }
  }
}
