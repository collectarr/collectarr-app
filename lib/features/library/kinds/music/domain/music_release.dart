import 'package:collectarr_app/core/api/dto/catalog/catalog_disc_dto.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_track_dto.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';
import 'music_media.dart';
import 'music_track.dart';

@immutable
final class MusicRelease {
  const MusicRelease({
    required this.id,
    required this.title,
    this.artist,
    this.publisher,
    this.catalogNumber,
    this.barcode,
    this.releaseDate,
    this.recordingDate,
    this.releaseStatus,
    this.releaseType,
    this.sortTitle,
    this.subtitle,
    this.studio,
    this.countryCode,
    this.language,
    this.coverImageUrl,
    this.genres = const [],
    this.contributions = const [],
    this.media = const [],
    this.tracks = const [],
    this.isLive,
    this.rawPayload = const <String, dynamic>{},
  });

  final MusicReleaseId id;
  final String title;
  final String? artist;
  final String? publisher;
  final String? catalogNumber;
  final String? barcode;
  final DateTime? releaseDate;
  final DateTime? recordingDate;
  final String? releaseStatus;
  final String? releaseType;
  final String? sortTitle;
  final String? subtitle;
  final String? studio;
  final String? countryCode;
  final String? language;
  final String? coverImageUrl;
  final List<String> genres;
  final List<Map<String, dynamic>> contributions;
  final List<MusicMedia> media;
  final List<MusicTrack> tracks;
  final bool? isLive;
  final Map<String, dynamic> rawPayload;

  MusicReleaseId get typedId => id;
  String? get upc => barcode;
  List<MusicMedia> get discs => media;
  String? get frontCoverUrl => coverImageUrl;
  DateTime? get originalReleaseDate => releaseDate;
  String? get instrument => tracks.firstOrNull?.instrument;
  String? get composition => tracks.firstOrNull?.composition;
  int? get rpm => media.firstOrNull?.rpm;
  String? get spars => media.firstOrNull?.spars;
  String? get soundType => media.firstOrNull?.soundType;
  String? get vinylColor => media.firstOrNull?.vinylColor;
  String? get vinylWeight => media.firstOrNull?.vinylWeight;
  String? get mediaCondition => media.firstOrNull?.mediaCondition;
  List<Map<String, dynamic>> get creators => contributions;

  List<CatalogDisc> get discsAsCatalog => [
        for (final disc in media)
          CatalogDiscDto(
            discNumber: disc.mediaNumber,
            name: disc.title,
            tracks: [
              for (final track in disc.tracks)
                CatalogTrackDto(
                  title: track.title,
                  position: track.position,
                  durationSeconds: track.durationSeconds,
                  artist: track.artist,
                  discNumber: disc.mediaNumber,
                ),
            ],
          ),
      ];

  factory MusicRelease.fromJson(Map<String, dynamic> json) {
    final media = _maps(json['media'] ?? json['discs'])
        .map(MusicMedia.fromJson)
        .toList(growable: false);
    final tracks =
        _maps(json['tracks']).map(MusicTrack.fromJson).toList(growable: false);
    return MusicRelease(
      id: MusicReleaseId(_text(json['id']) ?? ''),
      title: _text(json['title']) ?? 'Untitled item',
      artist: _text(json['artist']),
      publisher: _text(json['publisher']),
      catalogNumber: _text(json['catalog_number']),
      barcode: _text(json['barcode'] ?? json['upc']),
      releaseDate: _date(json['release_date']),
      recordingDate: _date(json['recording_date']),
      releaseStatus: _text(json['release_status']),
      releaseType: _text(json['release_type']),
      sortTitle: _text(json['sort_title']),
      subtitle: _text(json['subtitle']),
      studio: _text(json['studio']),
      countryCode: _text(json['country_code'] ?? json['country']),
      language: _text(json['language']),
      coverImageUrl: _text(json['cover_image_url']),
      genres: _strings(json['genres']),
      contributions: _maps(json['contributions'] ?? json['creators']),
      media: media,
      tracks: tracks.isEmpty
          ? media.expand((disc) => disc.tracks).toList()
          : tracks,
      isLive: json['is_live'] as bool?,
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': 'music',
        'title': title,
        if (artist != null) 'artist': artist,
        if (publisher != null) 'publisher': publisher,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (barcode != null) 'barcode': barcode,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (recordingDate != null)
          'recording_date': recordingDate!.toIso8601String(),
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (releaseType != null) 'release_type': releaseType,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (subtitle != null) 'subtitle': subtitle,
        if (studio != null) 'studio': studio,
        if (countryCode != null) 'country_code': countryCode,
        if (language != null) 'language': language,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (genres.isNotEmpty) 'genres': genres,
        if (contributions.isNotEmpty) 'contributions': contributions,
        'media': media.map((disc) => disc.toJson()).toList(),
        'tracks': tracks.map((track) => track.toJson()).toList(),
        if (isLive != null) 'is_live': isLive,
      };
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _date(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '');

List<String> _strings(Object? value) {
  if (value is! Iterable) return const <String>[];
  return [
    for (final entry in value)
      if (_text(entry) case final value?) value,
  ];
}

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! Iterable) return const <Map<String, dynamic>>[];
  return [
    for (final entry in value)
      if (entry is Map) Map<String, dynamic>.from(entry),
  ];
}
