import 'package:flutter/foundation.dart';

import 'game_ids.dart';

@immutable
final class GameRelease {
  const GameRelease({
    required this.id,
    required this.title,
    this.workId,
    this.platform,
    this.releaseDate,
    this.regionCode,
    this.format,
    this.publisher,
    this.catalogNumber,
    this.releaseStatus,
    this.language,
    this.barcode,
    this.coverImageUrl,
    this.rawPayload = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String? workId;
  final String? platform;
  final DateTime? releaseDate;
  final String? regionCode;
  final String? format;
  final String? publisher;
  final String? catalogNumber;
  final String? releaseStatus;
  final String? language;
  final String? barcode;
  final String? coverImageUrl;
  final Map<String, dynamic> rawPayload;

  GameReleaseId get typedId => GameReleaseId(id);

  factory GameRelease.fromJson(Map<String, dynamic> json) {
    return GameRelease(
      id: _textValue(json['id']) ?? '',
      title: _textValue(json['release_title']) ??
          _textValue(json['title']) ??
          'Release',
      workId: _textValue(json['work_id']),
      platform: _textValue(json['platform']),
      releaseDate: _dateValue(json['release_date']),
      regionCode: _textValue(json['region_code']) ?? _textValue(json['region']),
      format: _textValue(json['format']),
      publisher: _textValue(json['publisher']),
      catalogNumber: _textValue(json['catalog_number']),
      releaseStatus: _textValue(json['release_status']),
      language: _textValue(json['language']),
      barcode: _textValue(json['barcode']),
      coverImageUrl: _textValue(json['cover_image_url']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id,
        'kind': 'game',
        if (workId != null) 'work_id': workId,
        'release_title': title,
        if (platform != null) 'platform': platform,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (regionCode != null) 'region_code': regionCode,
        if (format != null) 'format': format,
        if (publisher != null) 'publisher': publisher,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (releaseStatus != null) 'release_status': releaseStatus,
        if (language != null) 'language': language,
        if (barcode != null) 'barcode': barcode,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      };

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _dateValue(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '');
  }
}
