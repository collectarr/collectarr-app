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
    const fields = {
      'id',
      'kind',
      'revision',
      'created_at',
      'updated_at',
      'title',
      'sort_title',
      'subtitle',
      'artist',
      'original_release_date',
      'recording_date',
      'studios',
      'is_live',
      'genres',
      'release_date',
      'publisher',
      'country_code',
      'barcode',
      'catalog_number',
      'packaging',
      'cover_image_url',
      'cover_image_key',
      'back_cover_image_url',
      'thumbnail_image_url',
      'local_cover_image_path',
      'local_back_image_path',
      'local_thumbnail_image_path',
      'extra',
      'spars_code',
      'external_links',
      'box_set',
      'contributions',
      'artist_credits',
      'discs',
    };
    final unsupported = json.keys.where((key) => !fields.contains(key));
    if (unsupported.isNotEmpty) {
      throw FormatException(
        'Unrecognized local Music field "${unsupported.first}".',
      );
    }
    if (json['kind'] != null && json['kind'] != 'music') {
      throw FormatException(
          'Expected local Music data, received ${json['kind']}.');
    }
    final discs = _maps(json['discs'], 'discs')
        .map(MusicDisc.fromJson)
        .toList(growable: false);
    return MusicAlbum(
      id: _catalogItemRef(json['id']),
      title: _requiredText(json['title'], 'title'),
      sortTitle: _optionalText(json['sort_title'], 'sort_title'),
      subtitle: _optionalText(json['subtitle'], 'subtitle'),
      artist: _optionalText(json['artist'], 'artist'),
      originalReleaseDateParts: _partialDate(
        json['original_release_date'],
      ),
      recordingDateParts: _partialDate(
        json['recording_date'],
      ),
      studios: _strings(json['studios'], 'studios'),
      isLive: json['is_live'] as bool?,
      genres: _strings(json['genres'], 'genres'),
      releaseDateParts: _partialDate(
        json['release_date'],
      ),
      publisher: _optionalText(json['publisher'], 'publisher'),
      countryCode: _optionalText(json['country_code'], 'country_code'),
      barcode: _optionalText(json['barcode'], 'barcode'),
      catalogNumber: _optionalText(json['catalog_number'], 'catalog_number'),
      packaging: _optionalText(json['packaging'], 'packaging'),
      coverImageUrl: _optionalText(json['cover_image_url'], 'cover_image_url'),
      coverImageKey: _optionalText(json['cover_image_key'], 'cover_image_key'),
      backCoverImageUrl:
          _optionalText(json['back_cover_image_url'], 'back_cover_image_url'),
      thumbnailImageUrl: _optionalText(
        json['thumbnail_image_url'],
        'thumbnail_image_url',
      ),
      localCoverImagePath: _optionalText(
          json['local_cover_image_path'], 'local_cover_image_path'),
      localBackImagePath:
          _optionalText(json['local_back_image_path'], 'local_back_image_path'),
      localThumbnailImagePath: _optionalText(
        json['local_thumbnail_image_path'],
        'local_thumbnail_image_path',
      ),
      extra: _strictStringList(json['extra']),
      sparsCode: _optionalText(json['spars_code'], 'spars_code'),
      externalLinks: _externalLinks(json),
      boxSet: _optionalText(json['box_set'], 'box_set'),
      contributions: [
        for (final value in _maps(json['contributions'], 'contributions'))
          MusicAlbumContribution.fromJson(value),
      ],
      artistCredits: _artistCredits(json['artist_credits']),
      discs: discs,
      revision: _requiredInt(json['revision'], 'revision', minimum: 1),
      createdAt: _optionalDateTime(json['created_at'], 'created_at'),
      updatedAt: _optionalDateTime(json['updated_at'], 'updated_at'),
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

CatalogItemRef? _catalogItemRef(Object? value) {
  if (value == null) return null;
  return CatalogItemRef(
    kind: CatalogMediaKind.music,
    id: _requiredText(value, 'id'),
  );
}

String _requiredText(Object? value, String field) {
  if (value is! String || value.isEmpty || value != value.trim()) {
    throw FormatException('Local Music $field must be non-empty trimmed text.');
  }
  return value;
}

String? _optionalText(Object? value, String field) {
  if (value == null) return null;
  return _requiredText(value, field);
}

int _requiredInt(Object? value, String field, {required int minimum}) {
  if (value is! int || value < minimum) {
    throw FormatException('Local Music $field must be an integer >= $minimum.');
  }
  return value;
}

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

DateTime? _optionalDateTime(Object? value, String field) {
  if (value == null) return null;
  if (value is! String) {
    throw FormatException('Local Music $field must be an ISO date-time.');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !value.contains('T') || value != value.trim()) {
    throw FormatException('Local Music $field must be an ISO date-time.');
  }
  return parsed.toUtc();
}

List<String> _strings(Object? value, String field) {
  if (value == null) return const [];
  if (value is! List) {
    throw FormatException('Local Music $field must be a list of strings.');
  }
  return [
    for (final (index, entry) in value.indexed)
      _requiredText(entry, '$field entry ${index + 1}'),
  ];
}

List<String> _strictStringList(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const FormatException('Local Music extra must be a list of strings.');
  }
  return List<String>.unmodifiable([
    for (final (index, entry) in value.indexed)
      _requiredText(entry, 'extra entry ${index + 1}'),
  ]);
}

List<Map<String, dynamic>> _maps(Object? value, String field) {
  if (value == null) return const [];
  if (value is! List) {
    throw FormatException('Local Music $field must be a list.');
  }
  return [
    for (final (index, entry) in value.indexed)
      if (entry is Map)
        Map<String, dynamic>.from(entry)
      else
        throw FormatException(
          'Local Music $field entry ${index + 1} must be an object.',
        ),
  ];
}

List<MusicArtistCredit> _artistCredits(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
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
  if (raw is! List) {
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
