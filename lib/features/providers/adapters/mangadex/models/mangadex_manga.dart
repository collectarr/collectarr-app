import 'package:flutter/foundation.dart';

@immutable
class MangaDexLocalizedText {
  const MangaDexLocalizedText(this.values);

  final Map<String, String> values;

  factory MangaDexLocalizedText.fromJson(Object? value) {
    if (value is! Map) return const MangaDexLocalizedText({});

    final values = <String, String>{};
    for (final entry in value.entries) {
      final text = _text(entry.value);
      if (text != null) values[entry.key.toString()] = text;
    }
    return MangaDexLocalizedText(Map.unmodifiable(values));
  }

  String? get preferred {
    for (final language in ['en', 'ja-ro', 'ja']) {
      final value = values[language];
      if (value != null && value.isNotEmpty) return value;
    }
    for (final value in values.values) {
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  Map<String, dynamic> toJson() => values;
}

@immutable
class MangaDexTag {
  const MangaDexTag({this.name});

  final MangaDexLocalizedText? name;

  factory MangaDexTag.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    final attributesMap = attributes is Map
        ? Map<String, dynamic>.from(attributes)
        : const <String, dynamic>{};
    return MangaDexTag(
      name: MangaDexLocalizedText.fromJson(attributesMap['name']),
    );
  }

  Map<String, dynamic> toJson() => {
        'attributes': {
          if (name != null) 'name': name!.toJson(),
        },
      };
}

@immutable
class MangaDexAttributes {
  const MangaDexAttributes({
    this.title,
    this.altTitles = const [],
    this.description,
    this.status,
    this.year,
    this.publicationDemographic,
    this.publisher,
    this.tags = const [],
  });

  final MangaDexLocalizedText? title;
  final List<MangaDexLocalizedText> altTitles;
  final MangaDexLocalizedText? description;
  final String? status;
  final int? year;
  final String? publicationDemographic;
  final String? publisher;
  final List<MangaDexTag> tags;

  factory MangaDexAttributes.fromJson(Map<String, dynamic> json) {
    return MangaDexAttributes(
      title: MangaDexLocalizedText.fromJson(json['title']),
      altTitles: _localizedList(json['altTitles']),
      description: MangaDexLocalizedText.fromJson(json['description']),
      status: _text(json['status']),
      year: _int(json['year']),
      publicationDemographic: _text(json['publicationDemographic']),
      publisher: _text(json['publisher']),
      tags: _tagList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title!.toJson(),
        if (altTitles.isNotEmpty)
          'altTitles': altTitles.map((title) => title.toJson()).toList(),
        if (description != null) 'description': description!.toJson(),
        if (status != null) 'status': status,
        if (year != null) 'year': year,
        if (publicationDemographic != null)
          'publicationDemographic': publicationDemographic,
        if (publisher != null) 'publisher': publisher,
        if (tags.isNotEmpty) 'tags': tags.map((tag) => tag.toJson()).toList(),
      };
}

@immutable
class MangaDexRelationship {
  const MangaDexRelationship({this.type, this.name, this.fileName});

  final String? type;
  final String? name;
  final String? fileName;

  factory MangaDexRelationship.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    final attributesMap = attributes is Map
        ? Map<String, dynamic>.from(attributes)
        : const <String, dynamic>{};
    return MangaDexRelationship(
      type: _text(json['type']),
      name: _text(attributesMap['name']),
      fileName: _text(attributesMap['fileName']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (name != null || fileName != null)
          'attributes': {
            if (name != null) 'name': name,
            if (fileName != null) 'fileName': fileName,
          },
      };
}

@immutable
class MangaDexManga {
  const MangaDexManga({
    this.id,
    this.attributes,
    this.relationships = const [],
  });

  final String? id;
  final MangaDexAttributes? attributes;
  final List<MangaDexRelationship> relationships;

  factory MangaDexManga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    return MangaDexManga(
      id: _text(json['id']),
      attributes: attributes is Map
          ? MangaDexAttributes.fromJson(Map<String, dynamic>.from(attributes))
          : null,
      relationships: _relationshipList(json['relationships']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (attributes != null) 'attributes': attributes!.toJson(),
        if (relationships.isNotEmpty)
          'relationships': relationships
              .map((relationship) => relationship.toJson())
              .toList(),
      };
}

List<MangaDexLocalizedText> _localizedList(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value) MangaDexLocalizedText.fromJson(item),
  ]);
}

List<MangaDexTag> _tagList(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map) MangaDexTag.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<MangaDexRelationship> _relationshipList(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map)
        MangaDexRelationship.fromJson(Map<String, dynamic>.from(item)),
  ]);
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
