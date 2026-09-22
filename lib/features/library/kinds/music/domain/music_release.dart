import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';
import 'music_medium.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'music_box_set_membership.dart';
import 'music_external_link.dart';
import 'music_release_relations.dart';
import 'music_track.dart';

/// MusicBrainz release: a concrete pressing/edition in a release group.
@immutable
final class MusicRelease implements JsonEncodable {
  MusicRelease({
    required this.id,
    required this.releaseGroupId,
    required this.title,
    this.sortTitle,
    this.subtitle,
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
    this.physicalFormat,
    this.physicalFormatLabel,
    this.coverImageUrl,
    this.coverImageKey,
    this.externalLinks = const [],
    this.boxSetMembership,
    this.contributions = const [],
    this.artistCredits = const [],
    this.labels = const [],
    this.identifiers = const [],
    this.mediums = const [],
    this.boxSetName,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt =
            createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt =
            updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  final MusicReleaseId id;
  final MusicReleaseGroupId releaseGroupId;
  final String title;
  final String? sortTitle;
  final String? subtitle;
  final String? releaseType;
  final String? releaseStatus;
  final DateTime? releaseDate;

  /// Preserves year/month precision when a provider only supplies a partial
  /// release date.
  final PartialDate? releaseDateParts;
  final String? publisher;
  final String? countryCode;
  final String? language;
  final String? barcode;
  final String? upc;
  final String? catalogNumber;
  final String? packaging;
  final String? physicalFormat;
  final String? physicalFormatLabel;
  final String? coverImageUrl;
  final String? coverImageKey;
  final List<MusicExternalLink> externalLinks;
  final MusicBoxSetMembership? boxSetMembership;
  final List<MusicReleaseContribution> contributions;
  final List<MusicArtistCredit> artistCredits;
  final List<MusicReleaseLabel> labels;
  final List<MusicReleaseIdentifier> identifiers;
  final List<MusicMedium> mediums;
  final String? boxSetName;
  final DateTime createdAt;
  final DateTime updatedAt;

  String? get boxSetTitle => boxSetName ?? boxSetMembership?.boxSetRef.id;

  int get trackCount => mediums.fold<int>(
      0, (total, medium) => total + medium.effectiveTrackCount);
  List<MusicTrack> get tracks => [
        for (final medium in mediums)
          for (final track in medium.tracks)
            if (!track.isHeader) track,
      ];

  factory MusicRelease.fromJson(Map<String, dynamic> json) {
    final mediums = _maps(json['mediums'])
        .map(MusicMedium.fromJson)
        .toList(growable: false);
    return MusicRelease(
      id: MusicReleaseId(_text(json['id']) ?? ''),
      releaseGroupId:
          MusicReleaseGroupId(_text(json['release_group_id']) ?? ''),
      title: _text(json['title']) ?? 'Untitled release',
      sortTitle: _text(json['sort_title']),
      subtitle: _text(json['subtitle']),
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
      physicalFormat: _text(json['physical_format']),
      physicalFormatLabel: _text(json['physical_format_label']),
      coverImageUrl: _text(json['cover_image_url']),
      coverImageKey: _text(json['cover_image_key']),
      externalLinks: _externalLinks(json),
      boxSetMembership: musicBoxSetMembershipFromJson(json),
      contributions: [
        for (final value in _maps(json['contributions']))
          MusicReleaseContribution.fromJson(value),
      ],
      artistCredits: [
        for (final value in _maps(json['artist_credits']))
          MusicArtistCredit.fromJson(value),
      ],
      labels: [
        for (final value in _maps(json['labels'] ?? json['label_info']))
          MusicReleaseLabel.fromJson(value),
      ],
      identifiers: [
        for (final value in _maps(json['identifiers']))
          MusicReleaseIdentifier.fromJson(value),
      ],
      mediums: mediums,
      boxSetName: _text(
        json['box_set_name'] ??
            json['box_set_title'] ??
            (json['box_set'] as Map?)?['title'] ??
            (json['box_set'] as Map?)?['name'],
      ),
      createdAt: _dateTime(json['created_at']),
      updatedAt: _dateTime(json['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id.value,
        'kind': 'music',
        'release_group_id': releaseGroupId.value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (subtitle != null) 'subtitle': subtitle,
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
        if (physicalFormat != null) 'physical_format': physicalFormat,
        if (physicalFormatLabel != null)
          'physical_format_label': physicalFormatLabel,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
        if (externalLinks.isNotEmpty)
          'external_links': externalLinks.map((link) => link.toJson()).toList(),
        if (boxSetMembership != null) 'box_set': boxSetMembership!.toJson(),
        if (boxSetName != null) 'box_set_name': boxSetName,
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

MusicBoxSetMembership? musicBoxSetMembershipFromJson(
    Map<String, dynamic> json) {
  final raw = json['box_set'];
  if (raw is Map) {
    try {
      return MusicBoxSetMembership.fromJson(Map<String, dynamic>.from(raw));
    } on FormatException {
      return null;
    }
  }

  // Accept the flattened form emitted by provider payloads.
  final rawRef = json['box_set_ref'] ?? json['box_set_id'];
  if (rawRef != null) {
    try {
      return MusicBoxSetMembership.fromJson({
        'box_set_ref': rawRef,
        'sequence_number': json['box_set_position'],
      });
    } on FormatException {
      return null;
    }
  }
  return null;
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

List<Map<String, dynamic>> _maps(Object? value) => value is Iterable
    ? [
        for (final entry in value)
          if (entry is Map) Map<String, dynamic>.from(entry)
      ]
    : const <Map<String, dynamic>>[];

List<MusicExternalLink> _externalLinks(Map<String, dynamic> json) {
  final values = <MusicExternalLink>[];
  final seen = <String>{};
  for (final source in [json['external_links'], json['trailer_urls']]) {
    for (final value in _maps(source)) {
      final url = _text(value['url']);
      if (url == null || !seen.add(url)) continue;
      values.add(MusicExternalLink.fromJson(value));
    }
  }
  return values;
}
