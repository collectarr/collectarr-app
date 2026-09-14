import 'package:flutter/foundation.dart';

@immutable
class MusicBrainzArtist {
  const MusicBrainzArtist({this.id, this.name});

  final String? id;
  final String? name;

  factory MusicBrainzArtist.fromJson(Map<String, dynamic> json) {
    return MusicBrainzArtist(
      id: _text(json['id']),
      name: _text(json['name']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
      };
}

@immutable
class MusicBrainzArtistCredit {
  const MusicBrainzArtistCredit({this.name, this.artist});

  final String? name;
  final MusicBrainzArtist? artist;

  factory MusicBrainzArtistCredit.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'];
    return MusicBrainzArtistCredit(
      name: _text(json['name']),
      artist: artist is Map
          ? MusicBrainzArtist.fromJson(Map<String, dynamic>.from(artist))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (artist != null) 'artist': artist!.toJson(),
      };
}

@immutable
class MusicBrainzLabel {
  const MusicBrainzLabel({this.id, this.name});

  final String? id;
  final String? name;

  factory MusicBrainzLabel.fromJson(Map<String, dynamic> json) {
    return MusicBrainzLabel(
      id: _text(json['id']),
      name: _text(json['name']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
      };
}

@immutable
class MusicBrainzLabelInfo {
  const MusicBrainzLabelInfo({this.catalogNumber, this.label});

  final String? catalogNumber;
  final MusicBrainzLabel? label;

  factory MusicBrainzLabelInfo.fromJson(Map<String, dynamic> json) {
    final label = json['label'];
    return MusicBrainzLabelInfo(
      catalogNumber: _text(json['catalog-number']),
      label: label is Map
          ? MusicBrainzLabel.fromJson(Map<String, dynamic>.from(label))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (catalogNumber != null) 'catalog-number': catalogNumber,
        if (label != null) 'label': label!.toJson(),
      };
}

@immutable
class MusicBrainzReleaseGroup {
  const MusicBrainzReleaseGroup({this.id, this.title});

  final String? id;
  final String? title;

  factory MusicBrainzReleaseGroup.fromJson(Map<String, dynamic> json) {
    return MusicBrainzReleaseGroup(
      id: _text(json['id']),
      title: _text(json['title']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
      };
}

@immutable
class MusicBrainzCoverArtArchive {
  const MusicBrainzCoverArtArchive({this.artwork = false, this.front = false});

  final bool artwork;
  final bool front;

  factory MusicBrainzCoverArtArchive.fromJson(Map<String, dynamic> json) {
    return MusicBrainzCoverArtArchive(
      artwork: json['artwork'] == true,
      front: json['front'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'artwork': artwork,
        'front': front,
      };
}

@immutable
class MusicBrainzTrack {
  const MusicBrainzTrack({
    this.position,
    this.title,
    this.length,
    this.artistCredits = const [],
  });

  final int? position;
  final String? title;
  final int? length;
  final List<MusicBrainzArtistCredit> artistCredits;

  factory MusicBrainzTrack.fromJson(Map<String, dynamic> json) {
    return MusicBrainzTrack(
      position: _int(json['position']),
      title: _text(json['title']),
      length: _int(json['length']),
      artistCredits: _artistCredits(json['artist-credit']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (position != null) 'position': position,
        if (title != null) 'title': title,
        if (length != null) 'length': length,
        if (artistCredits.isNotEmpty)
          'artist-credit':
              artistCredits.map((credit) => credit.toJson()).toList(),
      };
}

@immutable
class MusicBrainzMedium {
  const MusicBrainzMedium({
    this.trackCount,
    this.format,
    this.tracks = const [],
  });

  final int? trackCount;
  final String? format;
  final List<MusicBrainzTrack> tracks;

  factory MusicBrainzMedium.fromJson(Map<String, dynamic> json) {
    final tracks = json['tracks'];
    return MusicBrainzMedium(
      trackCount: _int(json['track-count']),
      format: _text(json['format']),
      tracks: tracks is List
          ? List.unmodifiable([
              for (final track in tracks)
                if (track is Map)
                  MusicBrainzTrack.fromJson(Map<String, dynamic>.from(track)),
            ])
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (trackCount != null) 'track-count': trackCount,
        if (format != null) 'format': format,
        if (tracks.isNotEmpty)
          'tracks': tracks.map((track) => track.toJson()).toList(),
      };
}

@immutable
class MusicBrainzRelease {
  const MusicBrainzRelease({
    this.id,
    this.title,
    this.date,
    this.country,
    this.barcode,
    this.artistCredits = const [],
    this.labelInfo = const [],
    this.releaseGroup,
    this.media = const [],
    this.coverArtArchive,
    this.genres = const [],
    this.tags = const [],
  });

  final String? id;
  final String? title;
  final String? date;
  final String? country;
  final String? barcode;
  final List<MusicBrainzArtistCredit> artistCredits;
  final List<MusicBrainzLabelInfo> labelInfo;
  final MusicBrainzReleaseGroup? releaseGroup;
  final List<MusicBrainzMedium> media;
  final MusicBrainzCoverArtArchive? coverArtArchive;
  final List<String> genres;
  final List<String> tags;

  factory MusicBrainzRelease.fromJson(Map<String, dynamic> json) {
    final releaseGroup = json['release-group'];
    final coverArtArchive = json['cover-art-archive'];
    return MusicBrainzRelease(
      id: _text(json['id']),
      title: _text(json['title']),
      date: _text(json['date']),
      country: _text(json['country']),
      barcode: _text(json['barcode']),
      artistCredits: _artistCredits(json['artist-credit']),
      labelInfo: _labelInfo(json['label-info']),
      releaseGroup: releaseGroup is Map
          ? MusicBrainzReleaseGroup.fromJson(
              Map<String, dynamic>.from(releaseGroup),
            )
          : null,
      media: _media(json['media']),
      coverArtArchive: coverArtArchive is Map
          ? MusicBrainzCoverArtArchive.fromJson(
              Map<String, dynamic>.from(coverArtArchive),
            )
          : null,
      genres: _namedTextList(json['genres']),
      tags: _namedTextList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (date != null) 'date': date,
        if (country != null) 'country': country,
        if (barcode != null) 'barcode': barcode,
        if (artistCredits.isNotEmpty)
          'artist-credit':
              artistCredits.map((credit) => credit.toJson()).toList(),
        if (labelInfo.isNotEmpty)
          'label-info': labelInfo.map((info) => info.toJson()).toList(),
        if (releaseGroup != null) 'release-group': releaseGroup!.toJson(),
        if (media.isNotEmpty)
          'media': media.map((medium) => medium.toJson()).toList(),
        if (coverArtArchive != null)
          'cover-art-archive': coverArtArchive!.toJson(),
        if (genres.isNotEmpty) 'genres': genres,
        if (tags.isNotEmpty) 'tags': tags,
      };
}

List<MusicBrainzArtistCredit> _artistCredits(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map)
        MusicBrainzArtistCredit.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<MusicBrainzLabelInfo> _labelInfo(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map)
        MusicBrainzLabelInfo.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<MusicBrainzMedium> _media(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map)
        MusicBrainzMedium.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<String> _namedTextList(Object? value) {
  if (value is! List) return const [];
  final names = <String>[];
  for (final item in value) {
    final name = item is Map ? _text(item['name']) : _text(item);
    if (name != null) names.add(name);
  }
  return List.unmodifiable(names);
}

int? _int(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

String? _text(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
