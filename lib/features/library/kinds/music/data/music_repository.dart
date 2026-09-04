import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/drift.dart';

final class MusicRepository {
  MusicRepository(this._db, {MusicRemoteSource? remote}) : _remote = remote;

  final LocalDatabase _db;
  final MusicRemoteSource? _remote;

  Future<MusicRelease?> getRelease(MusicReleaseId id) async {
    final row = await (_db.select(_db.musicReleaseRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row != null) return _hydrateRelease(row);

    final remote = _remote;
    if (remote == null) return null;
    final release = await remote.fetchRelease(id);
    await updateRelease(release);
    return release;
  }

  Future<List<MusicRelease>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.musicReleaseRows);
    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      select.where(
        (table) =>
            table.title.like(pattern) |
            table.sortTitle.like(pattern) |
            table.artist.like(pattern),
      );
    }
    select.orderBy([
      (table) => OrderingTerm.asc(table.sortTitle),
      (table) => OrderingTerm.asc(table.title),
      (table) => OrderingTerm.asc(table.id),
    ]);
    final rows = await select.get();
    return [for (final row in rows) await _hydrateRelease(row)];
  }

  Future<List<MusicMedia>> mediaFor(MusicReleaseId releaseId) async {
    final rows = await (_db.select(_db.musicMediaRows)
          ..where((table) => table.releaseId.equals(releaseId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.mediaNumber),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return [
      for (final row in rows)
        MusicLocalMapper.fromMediaRow(
          row,
          tracks: await tracksFor(MusicMediaId(row.id)),
        ),
    ];
  }

  Future<MusicMedia?> getMedia(
    MusicReleaseId releaseId,
    MusicMediaId mediaId,
  ) async {
    final row = await (_db.select(_db.musicMediaRows)
          ..where(
            (table) =>
                table.releaseId.equals(releaseId.value) &
                table.id.equals(mediaId.value),
          ))
        .getSingleOrNull();
    return row == null
        ? null
        : MusicLocalMapper.fromMediaRow(
            row,
            tracks: await tracksFor(mediaId),
          );
  }

  Future<List<MusicTrack>> tracksFor(MusicMediaId mediaId) async {
    final rows = await (_db.select(_db.musicTrackRows)
          ..where((table) => table.mediaId.equals(mediaId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.position),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows.map(MusicLocalMapper.fromTrackRow).toList(growable: false);
  }

  Future<MusicTrack?> getTrack(
    MusicMediaId mediaId,
    MusicTrackId trackId,
  ) async {
    final row = await (_db.select(_db.musicTrackRows)
          ..where(
            (table) =>
                table.mediaId.equals(mediaId.value) &
                table.id.equals(trackId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : MusicLocalMapper.fromTrackRow(row);
  }

  Future<void> updateRelease(MusicRelease release) async {
    _require(release.id.value, 'MusicRelease');
    for (final media in release.media) {
      _validateMediaBelongs(release.id, media);
    }

    await _db.transaction(() async {
      await _deleteReleaseGraph(release.id);
      await _db
          .into(_db.musicReleaseRows)
          .insertOnConflictUpdate(MusicLocalMapper.toReleaseRow(release));
      for (final media in release.media) {
        await _db.into(_db.musicMediaRows).insertOnConflictUpdate(
              MusicLocalMapper.toMediaRow(media),
            );
        for (final track in media.tracks) {
          _validateTrackBelongs(media.id, track);
          await _db.into(_db.musicTrackRows).insertOnConflictUpdate(
                MusicLocalMapper.toTrackRow(track),
              );
        }
      }
    });
  }

  Future<void> updateMedia(
    MusicReleaseId releaseId,
    MusicMedia media,
  ) async {
    _validateMediaBelongs(releaseId, media);
    for (final track in media.tracks) {
      _validateTrackBelongs(media.id, track);
    }

    await _db.transaction(() async {
      await (_db.delete(_db.musicTrackRows)
            ..where((table) => table.mediaId.equals(media.id.value)))
          .go();
      await _db.into(_db.musicMediaRows).insertOnConflictUpdate(
            MusicLocalMapper.toMediaRow(media),
          );
      for (final track in media.tracks) {
        await _db.into(_db.musicTrackRows).insertOnConflictUpdate(
              MusicLocalMapper.toTrackRow(track),
            );
      }
    });
  }

  Future<void> updateTrack(MusicMediaId mediaId, MusicTrack track) {
    _validateTrackBelongs(mediaId, track);
    return _db.into(_db.musicTrackRows).insertOnConflictUpdate(
          MusicLocalMapper.toTrackRow(track),
        );
  }

  Future<MusicOwnedDetails?> getOwnedDetails(String ownedItemId) async {
    final row = await (_db.select(_db.musicOwnedDetailsRows)
          ..where((table) => table.ownedItemId.equals(ownedItemId)))
        .getSingleOrNull();
    return row == null ? null : MusicLocalMapper.fromOwnedDetailsRow(row);
  }

  Future<void> updateOwnedDetails(
    String ownedItemId,
    MusicOwnedDetails details,
  ) {
    return _db.into(_db.musicOwnedDetailsRows).insertOnConflictUpdate(
          MusicLocalMapper.toOwnedDetailsRow(ownedItemId, details),
        );
  }

  Future<MusicRelease> _hydrateRelease(MusicReleaseRow row) async {
    return MusicLocalMapper.fromReleaseRow(
      row,
      media: await mediaFor(MusicReleaseId(row.id)),
    );
  }

  Future<void> _deleteReleaseGraph(MusicReleaseId releaseId) async {
    final mediaRows = await (_db.select(_db.musicMediaRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .get();
    for (final media in mediaRows) {
      await (_db.delete(_db.musicTrackRows)
            ..where((table) => table.mediaId.equals(media.id)))
          .go();
    }
    await (_db.delete(_db.musicMediaRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .go();
    await (_db.delete(_db.musicReleaseRows)
          ..where((table) => table.id.equals(releaseId.value)))
        .go();
  }

  static void _validateMediaBelongs(
    MusicReleaseId releaseId,
    MusicMedia media,
  ) {
    if (media.releaseId != releaseId) {
      throw StateError('Music media does not belong to the supplied release');
    }
  }

  static void _validateTrackBelongs(MusicMediaId mediaId, MusicTrack track) {
    if (track.mediaId != mediaId) {
      throw StateError('Music track does not belong to the supplied media');
    }
  }

  static void _require(String value, String label) {
    if (value.trim().isEmpty) {
      throw StateError('Cannot persist $label without an id');
    }
  }
}
