import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';
import 'music_external_link.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'music_release.dart';
import 'music_release_relations.dart';
import 'music_track.dart';

/// MusicBrainz release-group: the conceptual album/work with many releases.
@immutable
final class MusicReleaseGroup implements JsonEncodable {
  MusicReleaseGroup({
    required this.id,
    required this.title,
    this.sortTitle,
    this.artist,
    this.originalTitle,
    this.originalReleaseDate,
    this.originalReleaseDateParts,
    this.recordingDate,
    this.recordingDateParts,
    this.studio,
    this.isLive,
    this.genres = const [],
    this.artistCredits = const [],
    this.coverImageUrl,
    this.coverImageKey,
    this.releases = const [],
    this.externalLinks = const [],
    this.localCoverImagePath,
    this.localBackImagePath,
    this.localThumbnailImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final MusicReleaseGroupId id;
  final String title;
  final String? sortTitle;
  final String? artist;
  final String? originalTitle;
  final DateTime? originalReleaseDate;

  /// Preserves year/month precision when [originalReleaseDate] is not a full
  /// calendar date.
  final PartialDate? originalReleaseDateParts;
  final DateTime? recordingDate;
  final PartialDate? recordingDateParts;
  final String? studio;
  final bool? isLive;
  final List<String> genres;
  final List<MusicArtistCredit> artistCredits;
  final String? coverImageUrl;
  final String? coverImageKey;
  final List<MusicRelease> releases;
  final List<MusicExternalLink> externalLinks;
  final String? localCoverImagePath;
  final String? localBackImagePath;
  final String? localThumbnailImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  MusicRelease? get primaryRelease => releases.firstOrNull;
  DateTime? get releaseDate =>
      originalReleaseDate ?? primaryRelease?.releaseDate;
  int get releaseCount => releases.length;
  int get mediumCount => releases.fold<int>(
        0,
        (total, release) => total + release.mediums.length,
      );
  int get trackCount =>
      releases.fold<int>(0, (total, release) => total + release.trackCount);
  List<MusicTrackView> get tracks => [
        for (final release in releases)
          for (final medium in release.mediums)
            for (final track in medium.tracks)
              if (!track.isHeader)
                MusicTrackView(
                    release: release, mediumId: medium.id, track: track),
      ];

  factory MusicReleaseGroup.fromJson(Map<String, dynamic> json) {
    return MusicReleaseGroup(
      id: MusicReleaseGroupId(_text(json['id']) ?? ''),
      title: _text(json['title']) ?? 'Untitled release group',
      sortTitle: _text(json['sort_title']),
      artist: _text(json['artist']),
      originalTitle: _text(json['original_title']),
      originalReleaseDate: _date(json['original_release_date']),
      originalReleaseDateParts: _partialDate(
        json['original_release_date_parts'] ?? json['original_release_date'],
      ),
      recordingDate: _date(json['recording_date']),
      recordingDateParts: _partialDate(
        json['recording_date_parts'] ?? json['recording_date'],
      ),
      studio: _text(json['studio']),
      isLive: json['is_live'] as bool?,
      genres: _strings(json['genres']),
      artistCredits: [
        for (final value in _maps(json['artist_credits']))
          MusicArtistCredit.fromJson(value),
      ],
      coverImageUrl: _text(json['cover_image_url']),
      coverImageKey: _text(json['cover_image_key']),
      externalLinks: _externalLinks(json),
      localCoverImagePath: _text(json['local_cover_image_path']),
      localBackImagePath: _text(json['local_back_image_path']),
      localThumbnailImagePath: _text(json['local_thumbnail_image_path']),
      releases: [
        for (final release in _maps(json['releases']))
          MusicRelease.fromJson({
            ...release,
            'release_group_id':
                _text(release['release_group_id']) ?? _text(json['id']) ?? '',
          }),
      ],
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'kind': 'music',
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (artist != null) 'artist': artist,
        if (originalTitle != null) 'original_title': originalTitle,
        if (originalReleaseDateParts != null)
          'original_release_date': originalReleaseDateParts!.isoString
        else if (originalReleaseDate != null)
          'original_release_date': originalReleaseDate!.toIso8601String(),
        if (originalReleaseDateParts != null)
          'original_release_date_parts': originalReleaseDateParts!.toJson(),
        if (recordingDateParts != null)
          'recording_date': recordingDateParts!.isoString
        else if (recordingDate != null)
          'recording_date': recordingDate!.toIso8601String(),
        if (recordingDateParts != null)
          'recording_date_parts': recordingDateParts!.toJson(),
        if (studio != null) 'studio': studio,
        if (isLive != null) 'is_live': isLive,
        if (genres.isNotEmpty) 'genres': genres,
        if (artistCredits.isNotEmpty)
          'artist_credits':
              artistCredits.map((value) => value.toJson()).toList(),
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
        if (externalLinks.isNotEmpty)
          'external_links': externalLinks.map((link) => link.toJson()).toList(),
        if (localCoverImagePath != null)
          'local_cover_image_path': localCoverImagePath,
        if (localBackImagePath != null)
          'local_back_image_path': localBackImagePath,
        if (localThumbnailImagePath != null)
          'local_thumbnail_image_path': localThumbnailImagePath,
        'releases': releases.map((release) => release.toJson()).toList(),
      };
}

@immutable
final class MusicTrackView {
  const MusicTrackView(
      {required this.release, required this.mediumId, required this.track});

  final MusicRelease release;
  final MusicMediumId mediumId;
  final MusicTrack track;
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime? _date(Object? value) => _partialDate(value)?.asDateTime;

PartialDate? _partialDate(Object? value) {
  if (value is Map) {
    try {
      return PartialDate.fromJson(value);
    } on FormatException {
      return null;
    }
  }
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return null;
  try {
    return PartialDate.fromJson(raw);
  } on FormatException {
    final parsed = DateTime.tryParse(raw);
    return parsed == null ? null : PartialDate.fromDateTime(parsed);
  }
}

DateTime _dateTime(Object? value) =>
    _date(value) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

List<String> _strings(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text
      ]
    : const <String>[];

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry)
      ]
    : const <Map<String, dynamic>>[];

List<MusicExternalLink> _externalLinks(Map<String, dynamic> json) {
  final seen = <String>{};
  final links = <MusicExternalLink>[];
  for (final value in [
    ..._maps(json['external_links']),
    ..._maps(json['trailer_urls']),
  ]) {
    final url = _text(value['url']);
    if (url == null || !seen.add(url)) {
      continue;
    }
    links.add(MusicExternalLink.fromJson(value));
  }
  return links;
}
