import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/tracking/anime_watch_session.dart';
import 'package:drift/drift.dart';

final class AnimeWatchSessionCodec implements WatchSessionCodec {
  const AnimeWatchSessionCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  @override
  WatchSession create(WatchSessionCreateRequest request) {
    if (request.libraryEntryRef.kind != kind) {
      throw ArgumentError.value(
        request.libraryEntryRef.kind,
        'request.libraryEntryRef.kind',
        'Expected Anime watch session',
      );
    }
    return AnimeWatchSession(
      id: request.id,
      libraryEntryRef: request.libraryEntryRef,
      trackingEntryId: request.trackingEntryId,
      seasonNumber: request.seasonNumber,
      episodeNumber: request.episodeNumber,
      sourceType: request.sourceType,
      seenWhere: request.seenWhere,
      watchedAt: request.watchedAt ?? request.updatedAt,
      rating: request.rating,
      notes: request.notes,
      updatedAt: request.updatedAt,
    );
  }

  @override
  Future<List<WatchSession>> listActive(LocalDatabase db) async {
    final query = db.select(db.animeWatchSessionRows)
      ..where((row) => row.deletedAt.isNull());
    final rows = await query.get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<WatchSession?> findByRef(
    LocalDatabase db,
    WatchSessionRef ref,
  ) async {
    if (ref.kind != kind) return null;
    final row = await (db.select(db.animeWatchSessionRows)
          ..where((item) => item.id.equals(ref.id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> upsert(LocalDatabase db, WatchSession session) async {
    _validateKind(session);
    await db.into(db.animeWatchSessionRows).insertOnConflictUpdate(
          AnimeWatchSessionRowsCompanion.insert(
            id: session.id,
            libraryEntryId: session.libraryEntryRef.id.value,
            libraryEntryRefKey: session.libraryEntryRef.key,
            trackingEntryId: Value(session.trackingEntryId),
            seasonNumber: Value(session.seasonNumber),
            episodeNumber: Value(session.episodeNumber),
            sourceType: Value(session.sourceTypeApiValue),
            seenWhere: Value(session.seenWhere),
            watchedAt: session.watchedAt,
            rating: Value(session.rating),
            notes: Value(session.notes),
            updatedAt: session.updatedAt,
            deletedAt: Value(session.deletedAt),
          ),
        );
  }

  @override
  Map<String, dynamic> toSyncPayload(WatchSession session) {
    _validateKind(session);
    final typed = session as AnimeWatchSession;
    return typed.toSyncPayload()
      ..addAll({
        'season_number': typed.seasonNumber,
        'episode_number': typed.episodeNumber,
      });
  }

  @override
  WatchSession fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    final libraryEntryRef = _libraryEntryRefFromPayload(payload);
    if (libraryEntryRef.kind != kind) {
      throw ArgumentError.value(
        libraryEntryRef.kind,
        'payload.library_entry_ref.kind',
        'Expected Anime watch session',
      );
    }
    final seasonNumber = _int(payload['season_number']);
    final episodeNumber = _int(payload['episode_number']);
    return AnimeWatchSession(
      id: id,
      libraryEntryRef: libraryEntryRef,
      trackingEntryId: payload['tracking_entry_id'] as String?,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      sourceType: payload['source_type'] as String?,
      seenWhere: payload['seen_where'] as String?,
      watchedAt: DateTime.parse(payload['watched_at'] as String),
      rating: _int(payload['rating']),
      notes: payload['notes'] as String?,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  AnimeWatchSession _fromRow(AnimeWatchSessionRow row) {
    final libraryEntryRef = LibraryEntryRef.fromKey(row.libraryEntryRefKey);
    if (libraryEntryRef.kind != kind ||
        libraryEntryRef.id.value != row.libraryEntryId) {
      throw FormatException(
        'Anime watch session ${row.id} has a mismatched library entry reference.',
      );
    }
    return AnimeWatchSession(
      id: row.id,
      libraryEntryRef: libraryEntryRef,
      trackingEntryId: row.trackingEntryId,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      sourceType: trackingSourceTypeFromValue(row.sourceType),
      seenWhere: row.seenWhere,
      watchedAt: row.watchedAt,
      rating: row.rating,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  void _validateKind(WatchSession session) {
    if (session is! AnimeWatchSession || session.libraryEntryRef.kind != kind) {
      throw ArgumentError.value(
        session.libraryEntryRef.kind,
        'session.libraryEntryRef.kind',
        'Expected Anime watch session',
      );
    }
  }

  LibraryEntryRef _libraryEntryRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['library_entry_ref'];
    if (raw is! Map) {
      throw const FormatException(
        'Anime watch session is missing library_entry_ref',
      );
    }
    final ref = LibraryEntryRef.fromJson(Map<String, dynamic>.from(raw));
    if (ref.kind != kind) {
      throw const FormatException(
        'Anime watch session library_entry_ref must be an Anime entry.',
      );
    }
    return ref;
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
