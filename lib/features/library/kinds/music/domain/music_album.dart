import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:flutter/foundation.dart';

import 'music_disc.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'music_external_link.dart';
import 'music_album_relations.dart';
import 'music_track.dart';

/// One concrete Music Catalog Item representing an album edition.
///
/// Discs and tracks are contained children. Physical / format metadata belongs
/// exclusively to [MusicDisc].
@immutable
final class MusicAlbum implements JsonEncodable {
  MusicAlbum({
    this.id,
    required this.title,
    this.sortTitle,
    this.subtitle,
    this.artist,
    this.originalReleaseDateParts,
    this.recordingDateParts,
    List<String> studios = const [],
    this.isLive,
    List<String> genres = const [],
    this.releaseDateParts,
    this.publisher,
    this.countryCode,
    this.barcode,
    this.catalogNumber,
    this.packaging,
    this.coverImageUrl,
    this.coverImageKey,
    this.backCoverImageUrl,
    this.thumbnailImageUrl,
    this.localCoverImagePath,
    this.localBackImagePath,
    this.localThumbnailImagePath,
    List<String> extra = const [],
    this.sparsCode,
    this.externalLinks = const [],
    this.boxSet,
    this.contributions = const [],
    this.artistCredits = const [],
    this.discs = const [],
    this.revision = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : studios = List<String>.unmodifiable(studios),
        genres = List<String>.unmodifiable(genres),
        extra = List<String>.unmodifiable(extra),
        createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  /// Core identity is carried by [CatalogItemDto], not kind-owned metadata.
  /// This is present only while decoding a canonical transport item.
  final CatalogItemRef? id;
  final String title;
  final String? sortTitle;
  final String? subtitle;
  final String? artist;
  final PartialDate? originalReleaseDateParts;
  final PartialDate? recordingDateParts;
  final List<String> studios;
  final bool? isLive;
  final List<String> genres;

  /// Preserves year/month precision from partial catalog dates.
  final PartialDate? releaseDateParts;
  final String? publisher;
  final String? countryCode;
  final String? barcode;
  final String? catalogNumber;
  final String? packaging;

  /// Derived presentation summary computed directly from contained discs.
  String? get formatSummary => formatAlbumDiscsSummary(discs);

  final String? coverImageUrl;
  final String? coverImageKey;
  final String? backCoverImageUrl;
  final String? thumbnailImageUrl;
  final String? localCoverImagePath;
  final String? localBackImagePath;
  final String? localThumbnailImagePath;
  final List<String> extra;
  final String? sparsCode;
  final List<MusicExternalLink> externalLinks;
  final String? boxSet;
  final List<MusicAlbumContribution> contributions;
  final List<MusicArtistCredit> artistCredits;
  final List<MusicDisc> discs;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateTime? get originalReleaseDate => originalReleaseDateParts?.asDateTime;
  DateTime? get recordingDate => recordingDateParts?.asDateTime;
  DateTime? get releaseDate => releaseDateParts?.asDateTime;

  int get trackCount =>
      discs.fold<int>(0, (total, disc) => total + disc.effectiveTrackCount);
  List<MusicTrack> get tracks => [
        for (final disc in discs)
          for (final track in disc.tracks)
            if (!track.isHeader) track,
      ];

  factory MusicAlbum.fromJson(Map<String, dynamic> json) {
    final discs =
        _maps(json['discs']).map(MusicDisc.fromJson).toList(growable: false);
    return MusicAlbum(
      id: switch (_text(json['id'])) {
        final id? => CatalogItemRef(kind: CatalogMediaKind.music, id: id),
        null => null,
      },
      title: _text(json['title']) ?? 'Untitled album',
      sortTitle: _text(json['sort_title']),
      subtitle: _text(json['subtitle']),
      artist: _text(json['artist']),
      originalReleaseDateParts: _partialDate(
        json['original_release_date'],
      ),
      recordingDateParts: _partialDate(
        json['recording_date'],
      ),
      studios: _strings(json['studios']),
      isLive: json['is_live'] as bool?,
      genres: _strings(json['genres']),
      releaseDateParts: _partialDate(
        json['release_date'],
      ),
      publisher: _text(json['publisher']),
      countryCode: _text(json['country_code']),
      barcode: _text(json['barcode']),
      catalogNumber: _text(json['catalog_number']),
      packaging: _text(json['packaging']),
      coverImageUrl: _text(json['cover_image_url']),
      coverImageKey: _text(json['cover_image_key']),
      backCoverImageUrl: _text(json['back_cover_image_url']),
      thumbnailImageUrl: _text(json['thumbnail_image_url']),
      localCoverImagePath: _text(json['local_cover_image_path']),
      localBackImagePath: _text(json['local_back_image_path']),
      localThumbnailImagePath: _text(json['local_thumbnail_image_path']),
      extra: _strictStringList(json['extra']),
      sparsCode: _text(json['spars_code']),
      externalLinks: _externalLinks(json),
      boxSet: _text(json['box_set']),
      contributions: [
        for (final value in _maps(json['contributions']))
          MusicAlbumContribution.fromJson(value),
      ],
      artistCredits: _artistCredits(json['artist_credits']),
      discs: discs,
      revision: _int(json['revision']) ?? 1,
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id!.id,
        if (id != null) 'kind': id!.kind.apiValue,
        'revision': revision,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (subtitle != null) 'subtitle': subtitle,
        if (artist != null) 'artist': artist,
        if (originalReleaseDateParts != null)
          'original_release_date': originalReleaseDateParts!.toJson(),
        if (recordingDateParts != null)
          'recording_date': recordingDateParts!.toJson(),
        if (studios.isNotEmpty) 'studios': studios,
        if (isLive != null) 'is_live': isLive,
        if (genres.isNotEmpty) 'genres': genres,
        if (releaseDateParts != null)
          'release_date': releaseDateParts!.toJson(),
        if (publisher != null) 'publisher': publisher,
        if (countryCode != null) 'country_code': countryCode,
        if (barcode != null) 'barcode': barcode,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (packaging != null) 'packaging': packaging,
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
        'extra': extra,
        if (sparsCode != null) 'spars_code': sparsCode,
        if (externalLinks.isNotEmpty)
          'external_links': externalLinks.map((link) => link.toJson()).toList(),
        if (boxSet != null) 'box_set': boxSet,
        if (contributions.isNotEmpty)
          'contributions':
              contributions.map((value) => value.toJson()).toList(),
        if (artistCredits.isNotEmpty)
          'artist_credits':
              artistCredits.map((value) => value.toJson()).toList(),
        'discs': discs.map((disc) => disc.toJson()).toList(),
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

PartialDate? _partialDate(Object? value) {
  if (value == null) return null;
  if (value is! Map ||
      value.isEmpty ||
      value.keys.any((key) => !{'year', 'month', 'day'}.contains(key)) ||
      value.values.any(
        (part) => part != null && part is! int,
      ) ||
      !value.values.any((part) => part is int)) {
    throw const FormatException('Music dates must use PartialDate objects.');
  }
  final parsed = PartialDate.fromJson(Map<String, dynamic>.from(value));
  if ((parsed.year != null && (parsed.year! < 1 || parsed.year! > 9999)) ||
      (parsed.month != null && (parsed.month! < 1 || parsed.month! > 12)) ||
      (parsed.day != null && (parsed.day! < 1 || parsed.day! > 31)) ||
      (parsed.isFullDate && parsed.asDateTime == null)) {
    throw const FormatException(
        'Music dates must contain valid calendar values.');
  }
  return parsed;
}

DateTime _dateTime(Object? value) {
  if (value is DateTime) return value.toUtc();
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

List<String> _strings(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (_text(entry) case final text?) text,
      ]
    : const <String>[];

List<String> _strictStringList(Object? value) {
  if (value == null) return const [];
  if (value is! List || value.any((entry) => entry is! String)) {
    throw const FormatException('Music extra must be a list of strings.');
  }
  return List<String>.unmodifiable(value.cast<String>());
}

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry)
      ]
    : const <Map<String, dynamic>>[];

List<MusicArtistCredit> _artistCredits(Object? value) {
  if (value == null) return const [];
  if (value is! Iterable) {
    throw const FormatException('Music artist_credits must be a list.');
  }
  return [
    for (final (index, entry) in value.indexed)
      if (entry is Map)
        MusicArtistCredit.fromJson(Map<String, dynamic>.from(entry))
      else
        throw FormatException(
          'Music artist_credits entry ${index + 1} must be an object.',
        ),
  ];
}

List<MusicExternalLink> _externalLinks(Map<String, dynamic> json) {
  final raw = json['external_links'];
  if (raw == null) return const [];
  if (raw is! Iterable) {
    throw const FormatException('Music external_links must be a list.');
  }
  return [
    for (final (index, value) in raw.indexed)
      if (value is Map)
        MusicExternalLink.fromJson(Map<String, dynamic>.from(value))
      else
        throw FormatException(
          'Music external_links entry ${index + 1} must be an object.',
        ),
  ];
}
