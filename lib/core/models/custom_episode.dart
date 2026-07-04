import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

/// A user-created episode entry for a series that lacks provider data.
final class CustomEpisode {
  CustomEpisode({
    required this.id,
    required this.seriesRef,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.updatedAt,
    this.overview,
    this.airDate,
    this.runtimeMinutes,
    this.deletedAt,
  });

  final String id;
  final CatalogEntityRef seriesRef;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? overview;
  final String? airDate;
  final int? runtimeMinutes;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  String get itemId => seriesRef.id;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': seriesRef.toJson(),
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'title': title,
      if (overview != null) 'overview': overview,
      if (airDate != null) 'air_date': airDate,
      if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
    };
  }

  factory CustomEpisode.fromJson(Map<String, dynamic> json) {
    final catalogRefJson = json['catalog_ref'];
    final fallbackItemId = json['item_id'] as String? ?? '';
    final seriesRef = catalogRefJson is Map<String, dynamic>
        ? CatalogEntityRef.fromJson(catalogRefJson)
        : CatalogEntityRef(
            kind: 'tv',
            entityType: CatalogEntityType.work,
            id: fallbackItemId,
          );
    return CustomEpisode(
      id: json['id'] as String,
      seriesRef: seriesRef,
      seasonNumber: json['season_number'] as int,
      episodeNumber: json['episode_number'] as int,
      title: json['title'] as String,
      overview: json['overview'] as String?,
      airDate: json['air_date'] as String?,
      runtimeMinutes: json['runtime_minutes'] as int?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  CustomEpisode copyWith({
    CatalogEntityRef? seriesRef,
    String? title,
    String? overview,
    String? airDate,
    int? runtimeMinutes,
    int? episodeNumber,
    int? seasonNumber,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return CustomEpisode(
      id: id,
      seriesRef: seriesRef ?? this.seriesRef,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      airDate: airDate ?? this.airDate,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
