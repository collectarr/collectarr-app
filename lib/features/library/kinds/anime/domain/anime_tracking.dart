import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:flutter/foundation.dart';

import 'anime_ids.dart';

/// Anime-entry custom episode override.
///
/// Custom episode coordinates are deliberately kept in Anime's domain. The
/// mixed Collection feature must not use a common episode aggregate for TV and
/// Anime just because both happen to expose season/episode numbers.
@immutable
final class AnimeCustomEpisode {
  const AnimeCustomEpisode({
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

  final AnimeEpisodeId id;
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
}

