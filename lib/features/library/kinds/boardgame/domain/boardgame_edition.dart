import 'package:flutter/foundation.dart';

import 'boardgame_ids.dart';

@immutable
final class BoardGameEdition {
  const BoardGameEdition({
    required this.id,
    required this.title,
    this.titleValue,
    this.workId,
    this.editionTitle,
    this.ageRating,
    this.audienceRating,
    this.barcode,
    this.catalogNumber,
    this.country,
    this.coverImageUrl,
    this.description,
    this.format,
    this.language,
    this.maxPlayers,
    this.minAge,
    this.minPlayers,
    this.playingTimeMinutes,
    this.publisher,
    this.releaseDate,
    this.releaseStatus,
    this.rawPayload = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String? titleValue;
  final String? workId;
  final String? editionTitle;
  final String? ageRating;
  final String? audienceRating;
  final String? barcode;
  final String? catalogNumber;
  final String? country;
  final String? coverImageUrl;
  final String? description;
  final String? format;
  final String? language;
  final int? maxPlayers;
  final int? minAge;
  final int? minPlayers;
  final int? playingTimeMinutes;
  final String? publisher;
  final DateTime? releaseDate;
  final String? releaseStatus;
  final Map<String, dynamic> rawPayload;

  BoardGameEditionId get typedId => BoardGameEditionId(id);
  String? get bestPlayers => null;

  factory BoardGameEdition.fromJson(Map<String, dynamic> json) {
    return BoardGameEdition(
      id: _textValue(json['id']) ?? '',
      title: _textValue(json['edition_title']) ??
          _textValue(json['title']) ??
          'Edition',
      titleValue: _textValue(json['title']),
      workId: _textValue(json['work_id']),
      editionTitle: _textValue(json['edition_title']),
      ageRating: _textValue(json['age_rating']),
      audienceRating: _textValue(json['audience_rating']),
      barcode: _textValue(json['barcode']),
      catalogNumber: _textValue(json['catalog_number']),
      country: _textValue(json['country']),
      coverImageUrl: _textValue(json['cover_image_url']),
      description: _textValue(json['description']),
      format: _textValue(json['format']),
      language: _textValue(json['language']),
      maxPlayers: _intValue(json['max_players']),
      minAge: _intValue(json['min_age']),
      minPlayers: _intValue(json['min_players']),
      playingTimeMinutes: _intValue(json['playing_time_minutes']),
      publisher: _textValue(json['publisher']),
      releaseDate: _dateValue(json['release_date']),
      releaseStatus: _textValue(json['release_status']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id,
        'kind': 'boardgame',
        'title': titleValue ?? title,
        if (workId != null) 'work_id': workId,
        if (editionTitle != null) 'edition_title': editionTitle,
        if (ageRating != null) 'age_rating': ageRating,
        if (audienceRating != null) 'audience_rating': audienceRating,
        if (barcode != null) 'barcode': barcode,
        if (catalogNumber != null) 'catalog_number': catalogNumber,
        if (country != null) 'country': country,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (description != null) 'description': description,
        if (format != null) 'format': format,
        if (language != null) 'language': language,
        if (maxPlayers != null) 'max_players': maxPlayers,
        if (minAge != null) 'min_age': minAge,
        if (minPlayers != null) 'min_players': minPlayers,
        if (playingTimeMinutes != null)
          'playing_time_minutes': playingTimeMinutes,
        if (publisher != null) 'publisher': publisher,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (releaseStatus != null) 'release_status': releaseStatus,
      };

  static String? _textValue(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _dateValue(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '');
  }
}
