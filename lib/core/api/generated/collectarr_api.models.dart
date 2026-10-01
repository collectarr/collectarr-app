import 'package:flutter/foundation.dart';

import 'collectarr_api.enums.dart';

@immutable
abstract class TypedMetadataResponse {
  const TypedMetadataResponse(this.raw);

  final Map<String, dynamic> raw;

  String get id;
  String get title;
  String? get kind;
  CollectarrItemKind? get mediaKind => CollectarrItemKind.fromApiValue(kind);
  DateTime? get releaseDate;
  String? get coverImageUrl;
  String? get thumbnailImageUrl;
  String? get barcode;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

String _stringValue(dynamic value, {String fallback = ''}) =>
    value?.toString() ?? fallback;

String? _nullableString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _nullableInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _nullableDate(dynamic value) {
  final text = _nullableString(value);
  return text == null ? null : DateTime.tryParse(text);
}

/// A typed boundary for catalog responses whose kind-specific DTO is owned by
/// the kind module. Shared API consumers can inspect common fields and retain
/// the complete response without introducing another kind-specific model.
@immutable
final class RawTypedMetadataResponse extends TypedMetadataResponse {
  const RawTypedMetadataResponse._(
    super.raw, {
    required this.id,
    required this.title,
    required this.kind,
  });

  factory RawTypedMetadataResponse.fromJson(Map<String, dynamic> json) {
    final id = _nullableString(json['id']);
    final title = _nullableString(json['title']);
    if (id == null || title == null) {
      throw const FormatException('Catalog response requires id and title.');
    }
    return RawTypedMetadataResponse._(
      Map<String, dynamic>.from(json),
      id: id,
      title: title,
      kind: _nullableString(json['kind']),
    );
  }

  @override
  final String id;

  @override
  final String title;

  @override
  final String? kind;

  @override
  DateTime? get releaseDate =>
      _nullableDate(raw['release_date'] ?? raw['original_release_date']);

  @override
  String? get coverImageUrl => _nullableString(raw['cover_image_url']);

  @override
  String? get thumbnailImageUrl =>
      _nullableString(raw['thumbnail_image_url']) ?? coverImageUrl;

  @override
  String? get barcode => _nullableString(raw['barcode']);
}

List<dynamic> _dynamicList(dynamic value) {
  if (value is List) {
    return List<dynamic>.from(value);
  }
  return const <dynamic>[];
}

List<String> _stringList(dynamic value) {
  if (value is! List) {
    return const <String>[];
  }
  final result = <String>[];
  final seen = <String>{};
  for (final entry in value) {
    final text = entry?.toString().trim();
    if (text == null || text.isEmpty) {
      continue;
    }
    final marker = text.toLowerCase();
    if (seen.add(marker)) {
      result.add(text);
    }
  }
  return result;
}











class ComicWorkDto extends TypedMetadataResponse {
  const ComicWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.contributors,
    required this.description,
    required this.firstPublicationDate,
    required this.originalLanguage,
    required this.sortTitle,
    required this.subtitle,
    required this.issues,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<dynamic> contributors;
  final String? description;
  final DateTime? firstPublicationDate;
  final String? originalLanguage;
  final String? sortTitle;
  final String? subtitle;
  final List<dynamic> issues;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => firstPublicationDate;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory ComicWorkDto.fromJson(Map<String, dynamic> json) {
    return ComicWorkDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      contributors: _dynamicList(json['contributors']),
      description: _nullableString(json['description']),
      firstPublicationDate: _nullableDate(json['first_publication_date']),
      originalLanguage: _nullableString(json['original_language']),
      sortTitle: _nullableString(json['sort_title']),
      subtitle: _nullableString(json['subtitle']),
      issues: _dynamicList(json['issues']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.comic.apiValue,
    );
  }
}



List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) Map<String, dynamic>.from(entry),
  ];
}
