import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session.dart';

import 'tv_ids.dart';

final class TvWatchSession extends WatchSession {
  TvWatchSession({
    required super.id,
    required super.libraryEntryRef,
    required super.watchedAt,
    required super.updatedAt,
    this.episodeId,
    super.seasonNumber,
    super.episodeNumber,
    super.trackingEntryId,
    super.sourceType,
    super.seenWhere,
    super.rating,
    super.notes,
    super.deletedAt,
  });

  final TvEpisodeId? episodeId;

  @override
  TvWatchSession copyWith({
    String? id,
    LibraryEntryRef? libraryEntryRef,
    String? trackingEntryId,
    int? seasonNumber,
    int? episodeNumber,
    Object? sourceType,
    String? seenWhere,
    DateTime? watchedAt,
    int? rating,
    String? notes,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TvWatchSession(
      id: id ?? this.id,
      episodeId: episodeId,
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      watchedAt: watchedAt ?? this.watchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      sourceType: sourceType ?? this.sourceType,
      seenWhere: seenWhere ?? this.seenWhere,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'library_entry_ref': libraryEntryRef.toJson(),
        if (episodeId != null) 'episode_id': episodeId!.value,
        if (trackingEntryId != null) 'tracking_entry_id': trackingEntryId,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (sourceType != null) 'source_type': sourceType!.apiValue,
        if (seenWhere != null) 'seen_where': seenWhere,
        'watched_at': watchedAt.toUtc().toIso8601String(),
        if (rating != null) 'rating': rating,
        if (notes != null) 'notes': notes,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        if (deletedAt != null)
          'deleted_at': deletedAt!.toUtc().toIso8601String(),
      };

  factory TvWatchSession.fromJson(Map<String, dynamic> json) {
    final libraryEntryRef = json['library_entry_ref'];
    if (libraryEntryRef is! Map) {
      throw const FormatException(
        'TV watch session is missing library_entry_ref',
      );
    }
    final entryRef = LibraryEntryRef.fromJson(
      Map<String, dynamic>.from(libraryEntryRef),
    );
    if (entryRef.kind != CatalogMediaKind.tv) {
      throw const FormatException(
        'TV watch session must reference a TV library entry.',
      );
    }
    return TvWatchSession(
      id: _text(json['id']) ?? '',
      libraryEntryRef: entryRef,
      episodeId: _text(json['episode_id']) == null
          ? null
          : TvEpisodeId(_text(json['episode_id'])!),
      trackingEntryId: _text(json['tracking_entry_id']),
      seasonNumber: _int(json['season_number']),
      episodeNumber: _int(json['episode_number']),
      sourceType: trackingSourceTypeFromValue(json['source_type']),
      seenWhere: _text(json['seen_where']),
      watchedAt: DateTime.parse(json['watched_at'] as String),
      rating: _int(json['rating']),
      notes: _text(json['notes']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }
}

final class TvCustomEpisode {
  const TvCustomEpisode({
    required this.id,
    required this.libraryEntryRef,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.updatedAt,
    this.description,
    this.airDate,
    this.runtimeMinutes,
    this.stillImageUrl,
    this.localImagePath,
    this.thumbnailImageUrl,
    this.deletedAt,
  });

  final TvEpisodeId id;
  final LibraryEntryRef libraryEntryRef;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? description;
  final DateTime? airDate;
  final int? runtimeMinutes;
  final String? stillImageUrl;
  final String? localImagePath;
  final String? thumbnailImageUrl;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'library_entry_ref': libraryEntryRef.toJson(),
        'season_number': seasonNumber,
        'episode_number': episodeNumber,
        'title': title,
        if (description != null) 'description': description,
        if (airDate != null) 'air_date': airDate!.toUtc().toIso8601String(),
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (stillImageUrl != null) 'still_image_url': stillImageUrl,
        if (localImagePath != null) 'local_image_path': localImagePath,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        if (deletedAt != null)
          'deleted_at': deletedAt!.toUtc().toIso8601String(),
      };

  factory TvCustomEpisode.fromJson(Map<String, dynamic> json) {
    return TvCustomEpisode(
      id: TvEpisodeId(_text(json['id']) ?? ''),
      libraryEntryRef: LibraryEntryRef.fromJson(
        Map<String, dynamic>.from(json['library_entry_ref'] as Map),
      ),
      seasonNumber: _int(json['season_number']) ?? 0,
      episodeNumber: _int(json['episode_number']) ?? 0,
      title: _text(json['title']) ?? 'Untitled episode',
      description: _text(json['description'] ?? json['overview']),
      airDate: _date(json['air_date']),
      runtimeMinutes: _int(json['runtime_minutes']),
      stillImageUrl: _text(json['still_image_url']),
      localImagePath: _text(json['local_image_path']),
      thumbnailImageUrl: _text(json['thumbnail_image_url']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _date(json['deleted_at']),
    );
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

double? _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) => DateTime.tryParse(value?.toString() ?? '');
