import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:drift/drift.dart';

final class TvWatchSessionCodec implements WatchSessionCodec {
  const TvWatchSessionCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  Future<List<WatchSession>> listActive(LocalDatabase db) async {
    final rows = await (db.select(db.tvWatchSessionRows)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<WatchSession?> findByRef(LocalDatabase db, WatchSessionRef ref) async {
    if (ref.kind != kind) return null;
    final row = await (db.select(db.tvWatchSessionRows)
          ..where((item) => item.id.equals(ref.id)))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> upsert(LocalDatabase db, WatchSession session) async {
    final typed = _validateSession(session);
    await db.into(db.tvWatchSessionRows).insertOnConflictUpdate(
          TvWatchSessionRowsCompanion.insert(
            id: typed.id,
            libraryEntryId: typed.libraryEntryRef.id.value,
            libraryEntryRefKey: typed.libraryEntryRef.key,
            episodeId: Value(typed.episodeId?.value),
            trackingEntryId: Value(typed.trackingEntryId),
            seasonNumber: Value(typed.seasonNumber),
            episodeNumber: Value(typed.episodeNumber),
            sourceType: Value(typed.sourceTypeApiValue),
            seenWhere: Value(typed.seenWhere),
            watchedAt: typed.watchedAt,
            rating: Value(typed.rating),
            notes: Value(typed.notes),
            updatedAt: typed.updatedAt,
            deletedAt: Value(typed.deletedAt),
          ),
        );
  }

  @override
  Map<String, dynamic> toSyncPayload(WatchSession session) {
    final typed = _validateSession(session);
    return typed.toSyncPayload()
      ..addAll({
        'episode_id': typed.episodeId?.value,
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
    final entryRef = _entryRefFromPayload(payload);
    return TvWatchSession(
      id: id,
      libraryEntryRef: entryRef,
      episodeId: _text(payload['episode_id']) == null
          ? null
          : TvEpisodeId(_text(payload['episode_id'])!),
      trackingEntryId: _text(payload['tracking_entry_id']),
      seasonNumber: _int(payload['season_number']),
      episodeNumber: _int(payload['episode_number']),
      sourceType: payload['source_type'] as String?,
      seenWhere: _text(payload['seen_where']),
      watchedAt: DateTime.parse(payload['watched_at'] as String),
      rating: _int(payload['rating']),
      notes: _text(payload['notes']),
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  TvWatchSession _fromRow(TvWatchSessionRow row) {
    final entryRef = LibraryEntryRef.fromKey(row.libraryEntryRefKey);
    _validateEntryRef(entryRef);
    if (entryRef.id.value != row.libraryEntryId) {
      throw FormatException(
        'TV watch session ${row.id} has a mismatched library entry reference.',
      );
    }
    return TvWatchSession(
      id: row.id,
      libraryEntryRef: entryRef,
      episodeId: row.episodeId == null ? null : TvEpisodeId(row.episodeId!),
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

  TvWatchSession _validateSession(WatchSession session) {
    if (session is! TvWatchSession) {
      throw ArgumentError.value(
          session, 'session', 'Expected TV watch session');
    }
    _validateEntryRef(session.libraryEntryRef);
    return session;
  }

  void _validateEntryRef(LibraryEntryRef ref) {
    if (ref.kind != kind) {
      throw ArgumentError.value(
          ref.kind, 'libraryEntryRef.kind', 'Expected TV');
    }
  }

  LibraryEntryRef _entryRefFromPayload(Map<String, dynamic> payload) {
    final raw = payload['library_entry_ref'];
    if (raw is! Map) {
      throw const FormatException(
          'TV watch session is missing library_entry_ref');
    }
    final ref = LibraryEntryRef.fromJson(Map<String, dynamic>.from(raw));
    _validateEntryRef(ref);
    return ref;
  }
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
