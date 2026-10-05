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
/// Discs and tracks are contained children. The historical class name does
/// not represent a separate Release scope or parent album grouping.
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
    String? format,
    this.coverImageUrl,
    this.coverImageKey,
    this.backCoverImageUrl,
    this.thumbnailImageUrl,
    this.localCoverImagePath,
    this.localBackImagePath,
    this.localThumbnailImagePath,
    this.extra,
    List<String> soundTypes = const [],
    String? vinylColor,
    String? vinylWeight,
    int? rpm,
    String? spars,
    this.externalLinks = const [],
    this.boxSet,
    this.contributions = const [],
    this.artistCredits = const [],
    this.discs = const [],
    this.revision = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : _explicitFormat = format,
        _explicitSoundTypes = List<String>.unmodifiable(soundTypes),
        _explicitVinylColor = vinylColor,
        _explicitVinylWeight = vinylWeight,
        _explicitRpm = rpm,
        _explicitSpars = spars,
        studios = List<String>.unmodifiable(studios),
        genres = List<String>.unmodifiable(genres),
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

  final String? _explicitFormat;
  final List<String> _explicitSoundTypes;
  final String? _explicitVinylColor;
  final String? _explicitVinylWeight;
  final int? _explicitRpm;
  final String? _explicitSpars;

  /// Catalog-level format label derived from discs, falling back to explicit value.
  String? get format =>
      formatAlbumDiscsSummary(discs, fallback: _explicitFormat);

  final String? coverImageUrl;
  final String? coverImageKey;
  final String? backCoverImageUrl;
  final String? thumbnailImageUrl;
  final String? localCoverImagePath;
  final String? localBackImagePath;
  final String? localThumbnailImagePath;
  final String? extra;

  List<String> get soundTypes {
    final discSoundTypes = [
      for (final disc in discs) ...disc.soundTypes,
    ];
    if (discSoundTypes.isNotEmpty) {
      return List<String>.unmodifiable(discSoundTypes.toSet().toList());
    }
    return _explicitSoundTypes;
  }

  String? get vinylColor =>
      discs.where((d) => d.vinylColor != null).firstOrNull?.vinylColor ??
      _explicitVinylColor;

  String? get vinylWeight =>
      discs.where((d) => d.vinylWeight != null).firstOrNull?.vinylWeight ??
      _explicitVinylWeight;

  int? get rpm =>
      discs.where((d) => d.rpm != null).firstOrNull?.rpm ?? _explicitRpm;

  String? get spars =>
      discs.where((d) => d.spars != null).firstOrNull?.spars ?? _explicitSpars;
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
    var discs =
        _maps(json['discs']).map(MusicDisc.fromJson).toList(growable: false);
    final rawFormat = _text(json['format']);
    final rawSoundTypes = _strings(json['sound_types']);
    final rawVinylColor = _text(json['vinyl_color']);
    final rawVinylWeight = _text(json['vinyl_weight']);
    final rawRpm = _int(json['rpm']);
    final rawSpars = _text(json['spars']);
    if (discs.isNotEmpty &&
        discs.every((d) => d.format == null && d.vinylColor == null)) {
      discs = [
        for (var i = 0; i < discs.length; i++)
          if (i == 0)
            MusicDisc(
              id: discs[i].id,
              discNumber: discs[i].discNumber,
              title: discs[i].title,
              format: rawFormat,
              soundTypes: rawSoundTypes,
              vinylColor: rawVinylColor,
              vinylWeight: rawVinylWeight,
              rpm: rawRpm,
              spars: rawSpars,
              matrixNumberSideA: discs[i].matrixNumberSideA,
              matrixNumberSideB: discs[i].matrixNumberSideB,
              tracks: discs[i].tracks,
            )
          else
            discs[i],
      ];
    }
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
        json['original_release_date_parts'] ?? json['original_release_date'],
      ),
      recordingDateParts: _partialDate(
        json['recording_date_parts'] ?? json['recording_date'],
      ),
      studios: _strings(json['studios']),
      isLive: json['is_live'] as bool?,
      genres: _strings(json['genres']),
      releaseDateParts: _partialDate(
        json['release_date_parts'] ?? json['release_date'],
      ),
      publisher: _text(json['publisher']),
      countryCode: _text(json['country_code']),
      barcode: _text(json['barcode']),
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
          'original_release_date': originalReleaseDateParts!.isoString,
        if (originalReleaseDateParts != null)
          'original_release_date_parts': originalReleaseDateParts!.toJson(),
        if (recordingDateParts != null)
          'recording_date': recordingDateParts!.isoString,
        if (recordingDateParts != null)
          'recording_date_parts': recordingDateParts!.toJson(),
        if (studios.isNotEmpty) 'studios': studios,
        if (isLive != null) 'is_live': isLive,
        if (genres.isNotEmpty) 'genres': genres,
        if (releaseDateParts != null)
          'release_date': releaseDateParts!.isoString,
        if (releaseDateParts != null)
          'release_date_parts': releaseDateParts!.toJson(),
        if (publisher != null) 'publisher': publisher,
        if (countryCode != null) 'country_code': countryCode,
        if (barcode != null) 'barcode': barcode,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (packaging != null) 'packaging': packaging,
        if (format != null) 'format': format,
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
