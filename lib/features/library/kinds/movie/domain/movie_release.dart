import 'package:flutter/foundation.dart';

import 'movie_ids.dart';

@immutable
final class MovieReleaseMedia {
  const MovieReleaseMedia({
    required this.id,
    required this.releaseId,
    this.mediaNumber,
    this.mediaType,
    this.title,
    this.numDiscs,
    this.nrLayers,
    this.aspectRatio,
    this.screenRatio,
    this.color,
    this.audioTracks,
    this.subtitles,
    this.layers,
    this.rawPayload = const <String, dynamic>{},
  });

  final MovieReleaseMediaId id;
  final String releaseId;
  final int? mediaNumber;
  final String? mediaType;
  final String? title;
  final int? numDiscs;
  final int? nrLayers;
  final String? aspectRatio;
  final String? screenRatio;
  final String? color;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;
  final Map<String, dynamic> rawPayload;

  factory MovieReleaseMedia.fromJson(Map<String, dynamic> json) {
    return MovieReleaseMedia(
      id: MovieReleaseMediaId(_textValue(json['id']) ?? ''),
      releaseId: _textValue(json['release_id']) ?? '',
      mediaNumber: _intValue(json['media_number']),
      mediaType: _textValue(json['media_type']),
      title: _textValue(json['title']),
      numDiscs: _intValue(json['num_discs']),
      nrLayers: _intValue(json['nr_layers']),
      aspectRatio: _textValue(json['aspect_ratio']),
      screenRatio: _textValue(json['screen_ratio']),
      color: _textValue(json['color']),
      audioTracks: _textValue(json['audio_tracks']),
      subtitles: _textValue(json['subtitles']),
      layers: _textValue(json['layers']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'release_id': releaseId,
        if (mediaNumber != null) 'media_number': mediaNumber,
        if (mediaType != null) 'media_type': mediaType,
        if (title != null) 'title': title,
        if (numDiscs != null) 'num_discs': numDiscs,
        if (nrLayers != null) 'nr_layers': nrLayers,
        if (aspectRatio != null) 'aspect_ratio': aspectRatio,
        if (screenRatio != null) 'screen_ratio': screenRatio,
        if (color != null) 'color': color,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
        if (layers != null) 'layers': layers,
      };

  MovieReleaseMediaId get typedId => id;

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

@immutable
final class MovieExternalLink {
  const MovieExternalLink({
    this.id,
    this.url,
    this.title,
    this.label,
    this.site,
    this.linkType,
    this.rawPayload = const <String, dynamic>{},
  });

  final String? id;
  final String? url;
  final String? title;
  final String? label;
  final String? site;
  final String? linkType;
  final Map<String, dynamic> rawPayload;

  factory MovieExternalLink.fromJson(Object? value) {
    if (value is! Map<Object?, Object?>) {
      return MovieExternalLink(url: _textValue(value));
    }
    final json = Map<String, dynamic>.from(value);
    return MovieExternalLink(
      id: _textValue(json['id']),
      url: _textValue(json['url']) ?? _textValue(json['href']),
      title: _textValue(json['title']),
      label: _textValue(json['label']),
      site: _textValue(json['site']) ?? _textValue(json['source']),
      linkType: _textValue(json['type']) ?? _textValue(json['kind']),
      rawPayload: json,
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        if (id != null) 'id': id,
        if (url != null) 'url': url,
        if (title != null) 'title': title,
        if (label != null) 'label': label,
        if (site != null) 'site': site,
        if (linkType != null) 'type': linkType,
      };

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

@immutable
final class MovieTrailerLink {
  const MovieTrailerLink({
    this.id,
    this.url,
    this.title,
    this.site,
    this.rawPayload = const <String, dynamic>{},
  });

  final String? id;
  final String? url;
  final String? title;
  final String? site;
  final Map<String, dynamic> rawPayload;

  factory MovieTrailerLink.fromJson(Object? value) {
    if (value is! Map<Object?, Object?>) {
      return MovieTrailerLink(url: _textValue(value));
    }
    final json = Map<String, dynamic>.from(value);
    return MovieTrailerLink(
      id: _textValue(json['id']),
      url: _textValue(json['url']) ?? _textValue(json['href']),
      title: _textValue(json['title']) ?? _textValue(json['name']),
      site: _textValue(json['site']) ?? _textValue(json['source']),
      rawPayload: json,
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        if (id != null) 'id': id,
        if (url != null) 'url': url,
        if (title != null) 'title': title,
        if (site != null) 'site': site,
      };

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

@immutable
final class MovieRelease {
  const MovieRelease({
    required this.id,
    required this.title,
    this.workId,
    this.coverImageKey,
    this.coverImageUrl,
    this.description,
    this.distributor,
    this.externalLinks = const [],
    this.format,
    this.language,
    this.media = const [],
    this.region,
    this.releaseDate,
    this.trailerUrls = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  final MovieReleaseId id;
  final String title;
  final String? workId;
  final String? coverImageKey;
  final String? coverImageUrl;
  final String? description;
  final String? distributor;
  final List<MovieExternalLink> externalLinks;
  final String? format;
  final String? language;
  final List<MovieReleaseMedia> media;
  final String? region;
  final DateTime? releaseDate;
  final List<MovieTrailerLink> trailerUrls;
  final Map<String, dynamic> rawPayload;

  String get releaseTitle => title;
  MovieReleaseId get typedId => id;
  MovieMediaId? get typedWorkId =>
      workId == null ? null : MovieMediaId(workId!);

  factory MovieRelease.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'];
    return MovieRelease(
      id: MovieReleaseId(_textValue(json['id']) ?? ''),
      title: _textValue(json['release_title']) ??
          _textValue(json['title']) ??
          'Untitled release',
      workId: _textValue(json['work_id']),
      coverImageKey: _textValue(json['cover_image_key']),
      coverImageUrl: _textValue(json['cover_image_url']),
      description: _textValue(json['description']),
      distributor: _textValue(json['distributor']),
      externalLinks: _mapExternalLinks(json['external_links']),
      format: _textValue(json['format']),
      language: _textValue(json['language']),
      media: rawMedia is List
          ? [
              for (final entry in rawMedia)
                if (entry is Map<Object?, Object?>)
                  MovieReleaseMedia.fromJson(
                    Map<String, dynamic>.from(entry),
                  ),
            ]
          : const <MovieReleaseMedia>[],
      region: _textValue(json['region']),
      releaseDate: _dateValue(json['release_date']),
      trailerUrls: _mapTrailerLinks(json['trailer_urls']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': 'movie',
        if (workId != null) 'work_id': workId,
        'release_title': title,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (description != null) 'description': description,
        if (distributor != null) 'distributor': distributor,
        'external_links': externalLinks.map((link) => link.toJson()).toList(),
        if (format != null) 'format': format,
        if (language != null) 'language': language,
        'media': media.map((entry) => entry.toJson()).toList(),
        if (region != null) 'region': region,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        'trailer_urls': trailerUrls.map((link) => link.toJson()).toList(),
      };

  static List<MovieExternalLink> _mapExternalLinks(Object? value) {
    if (value is! List) return const <MovieExternalLink>[];
    return [for (final entry in value) MovieExternalLink.fromJson(entry)];
  }

  static List<MovieTrailerLink> _mapTrailerLinks(Object? value) {
    if (value is! List) return const <MovieTrailerLink>[];
    return [for (final entry in value) MovieTrailerLink.fromJson(entry)];
  }

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _dateValue(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '');
  }
}
