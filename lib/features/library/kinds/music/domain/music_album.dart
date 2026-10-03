import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';
import 'music_medium.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'music_external_link.dart';
import 'music_album_relations.dart';
import 'music_track.dart';

/// One concrete Music Catalog Item representing an album edition.
///
/// Discs and tracks are contained children. The historical class name does
/// not represent a separate Release scope or parent album grouping.
@immutable
final class MusicAlbum implements JsonEncodable {
  MusicAlbum({
    required this.id,
    required this.title,
    this.sortTitle,
    this.subtitle,
    this.artist,
    this.originalTitle,
    this.originalReleaseDate,
    this.originalReleaseDateParts,
    this.recordingDate,
    this.recordingDateParts,
    List<String> studios = const [],
    this.isLive,
    List<String> genres = const [],
    this.releaseType,
    this.releaseStatus,
    this.releaseDate,
    this.releaseDateParts,
    this.publisher,
    this.countryCode,
    this.language,
    this.barcode,
    this.upc,
    this.catalogNumber,
    this.packaging,
    this.format,
    this.coverImageUrl,
    this.coverImageKey,
    this.backCoverImageUrl,
    this.thumbnailImageUrl,
    this.localCoverImagePath,
    this.localBackImagePath,
    this.localThumbnailImagePath,
    this.extra,
    List<String> soundTypes = const [],
    this.vinylColor,
    this.vinylWeight,
    this.rpm,
    this.spars,
    this.externalLinks = const [],
    this.boxSet,
    this.contributions = const [],
    this.artistCredits = const [],
    this.labels = const [],
    this.identifiers = const [],
    this.mediums = const [],
    this.mediumTypesSummary = const [],
    this.revision = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : studios = List<String>.unmodifiable(studios),
        genres = List<String>.unmodifiable(genres),
        soundTypes = List<String>.unmodifiable(soundTypes),
        createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final MusicAlbumId id;
  final String title;
  final String? sortTitle;
  final String? subtitle;
  final String? artist;
  final String? originalTitle;
  final DateTime? originalReleaseDate;
  final PartialDate? originalReleaseDateParts;
  final DateTime? recordingDate;
  final PartialDate? recordingDateParts;
  final List<String> studios;
  final bool? isLive;
  final List<String> genres;
  final String? releaseType;
  final String? releaseStatus;
  final DateTime? releaseDate;

  /// Preserves year/month precision from partial catalog dates.
  final PartialDate? releaseDateParts;
  final String? publisher;
  final String? countryCode;
  final String? language;
  final String? barcode;
  final String? upc;
  final String? catalogNumber;
  final String? packaging;

  /// Catalog-level format label returned by Core, independent of disc rows.
  final String? format;
  final String? coverImageUrl;
  final String? coverImageKey;
  final String? backCoverImageUrl;
  final String? thumbnailImageUrl;
  final String? localCoverImagePath;
  final String? localBackImagePath;
  final String? localThumbnailImagePath;
  final String? extra;
  final List<String> soundTypes;
  final String? vinylColor;
  final String? vinylWeight;
  final int? rpm;
  final String? spars;
  final List<MusicExternalLink> externalLinks;
  final String? boxSet;
  final List<MusicAlbumContribution> contributions;
  final List<MusicArtistCredit> artistCredits;
  final List<MusicAlbumLabel> labels;
  final List<MusicAlbumIdentifier> identifiers;
  final List<MusicMedium> mediums;

  /// Medium types carried by release summaries when full medium rows are not
  /// loaded. When [mediums] are present, their values take precedence.
  final List<String> mediumTypesSummary;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;

  List<String> get mediumTypes {
    final source = mediums.isEmpty
        ? mediumTypesSummary
        : [
            for (final medium in mediums)
              if (medium.mediumType case final type?) type
          ];
    final seen = <String>{};
    return [
      for (final value in source)
        if (value.trim().isNotEmpty && seen.add(value.trim().toLowerCase()))
          value.trim(),
    ];
  }

  String? get physicalFormat {
    final value = mediumTypes.firstOrNull;
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('vinyl') ||
        normalized == 'lp' ||
        normalized == 'record') {
      return 'vinyl';
    }
    if (normalized == 'cd' || normalized.contains('compact disc')) return 'cd';
    if (normalized.contains('cassette') || normalized == 'tape') {
      return 'cassette';
    }
    if (normalized.contains('digital')) return 'digital-audio';
    return value;
  }

  String? get physicalFormatLabel =>
      mediumTypes.isEmpty ? null : mediumTypes.join(' + ');

  int get trackCount => mediums.fold<int>(
      0, (total, medium) => total + medium.effectiveTrackCount);
  List<MusicTrack> get tracks => [
        for (final medium in mediums)
          for (final track in medium.tracks)
            if (!track.isHeader) track,
      ];

  factory MusicAlbum.fromJson(Map<String, dynamic> json) {
    final mediums = _maps(json['mediums'])
        .map(MusicMedium.fromJson)
        .toList(growable: false);
    return MusicAlbum(
      id: MusicAlbumId(_text(json['id']) ?? ''),
      title: _text(json['title']) ?? 'Untitled album',
      sortTitle: _text(json['sort_title']),
      subtitle: _text(json['subtitle']),
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
      studios: _strings(json['studios']),
      isLive: json['is_live'] as bool?,
      genres: _strings(json['genres']),
      releaseType: _text(json['release_type']),
      releaseStatus: _text(json['release_status']),
      releaseDate: _date(json['release_date']),
      releaseDateParts: _partialDate(
        json['release_date_parts'] ?? json['release_date'],
      ),
      publisher: _text(json['publisher']),
      countryCode: _text(json['country_code']),
      language: _text(json['language']),
      barcode: _text(json['barcode']),
      upc: _text(json['upc']),
      catalogNumber: _text(json['catalog_number']),
      packaging: _text(json['packaging']),
      format: _text(json['format']),
      coverImageUrl: _text(json['cover_image_url']),
      coverImageKey: _text(json['cover_image_key']),
      backCoverImageUrl: _text(json['back_cover_image_url']),
      thumbnailImageUrl: _text(json['thumbnail_image_url']),
      localCoverImagePath: _text(json['local_cover_image_path']),
      localBackImagePath: _text(json['local_back_image_path']),
      localThumbnailImagePath: _text(json['local_thumbnail_image_path']),
      extra: _text(json['extra']),
      soundTypes: _strings(json['sound_types']),
      vinylColor: _text(json['vinyl_color']),
      vinylWeight: _text(json['vinyl_weight']),
      rpm: _int(json['rpm']),
      spars: _text(json['spars']),
      externalLinks: _externalLinks(json),
      boxSet: _text(json['box_set']),
      contributions: [
        for (final value in _maps(json['contributions']))
          MusicAlbumContribution.fromJson(value),
      ],
      artistCredits: [
        for (final value in _maps(json['artist_credits']))
          MusicArtistCredit.fromJson(value),
      ],
      labels: [
        for (final value in _maps(json['labels']))
          MusicAlbumLabel.fromJson(value),
      ],
      identifiers: [
        for (final value in _maps(json['identifiers']))
          MusicAlbumIdentifier.fromJson(value),
      ],
      mediums: mediums,
      mediumTypesSummary: _strings(json['medium_types']),
      revision: _int(json['revision']) ?? 1,
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'kind': 'music',
        'revision': revision,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (subtitle != null) 'subtitle': subtitle,
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
        if (studios.isNotEmpty) 'studios': studios,
        if (isLive != null) 'is_live': isLive,
        if (genres.isNotEmpty) 'genres': genres,
        if (releaseType != null) 'release_type': releaseType,
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (releaseDateParts != null)
          'release_date': releaseDateParts!.isoString
        else if (releaseDate != null)
          'release_date': releaseDate!.toIso8601String(),
        if (releaseDateParts != null)
          'release_date_parts': releaseDateParts!.toJson(),
        if (publisher != null) 'publisher': publisher,
        if (countryCode != null) 'country_code': countryCode,
        if (language != null) 'language': language,
        if (barcode != null) 'barcode': barcode,
        if (upc != null) 'upc': upc,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (packaging != null) 'packaging': packaging,
        if (format != null) 'format': format,
        if (mediumTypes.isNotEmpty) 'medium_types': mediumTypes,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
        if (backCoverImageUrl != null)
          'back_cover_image_url': backCoverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        if (localCoverImagePath != null)
          'local_cover_image_path': localCoverImagePath,
        if (localBackImagePath != null)
          'local_back_image_path': localBackImagePath,
        if (localThumbnailImagePath != null)
          'local_thumbnail_image_path': localThumbnailImagePath,
        if (extra != null) 'extra': extra,
        if (soundTypes.isNotEmpty) 'sound_types': soundTypes,
        if (vinylColor != null) 'vinyl_color': vinylColor,
        if (vinylWeight != null) 'vinyl_weight': vinylWeight,
        if (rpm != null) 'rpm': rpm,
        if (spars != null) 'spars': spars,
        if (externalLinks.isNotEmpty)
          'external_links': externalLinks.map((link) => link.toJson()).toList(),
        if (boxSet != null) 'box_set': boxSet,
        if (contributions.isNotEmpty)
          'contributions':
              contributions.map((value) => value.toJson()).toList(),
        if (artistCredits.isNotEmpty)
          'artist_credits':
              artistCredits.map((value) => value.toJson()).toList(),
        if (labels.isNotEmpty)
          'labels': labels.map((value) => value.toJson()).toList(),
        if (identifiers.isNotEmpty)
          'identifiers': identifiers.map((value) => value.toJson()).toList(),
        'mediums': mediums.map((medium) => medium.toJson()).toList(),
      };
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _int(Object? value) => value is int
    ? value
    : value is num
        ? value.toInt()
        : int.tryParse(value?.toString().trim() ?? '');

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

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry)
      ]
    : const <Map<String, dynamic>>[];

List<String> _strings(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text,
      ]
    : const <String>[];

List<MusicExternalLink> _externalLinks(Map<String, dynamic> json) {
  final values = <MusicExternalLink>[];
  final seen = <String>{};
  for (final value in _maps(json['external_links'])) {
    final url = _text(value['url']);
    if (url == null || !seen.add(url)) continue;
    values.add(MusicExternalLink.fromJson(value));
  }
  return values;
}
