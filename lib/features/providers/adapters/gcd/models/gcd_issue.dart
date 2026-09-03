import 'package:flutter/foundation.dart';

@immutable
class GcdStory {
  const GcdStory({
    this.title,
    this.synopsis,
    this.script,
    this.pencils,
    this.inks,
    this.colors,
    this.letters,
    this.editing,
    this.characters,
    this.partOfIssueStoryArc,
  });

  final String? title;
  final String? synopsis;
  final String? script;
  final String? pencils;
  final String? inks;
  final String? colors;
  final String? letters;
  final String? editing;
  final String? characters;
  final String? partOfIssueStoryArc;

  factory GcdStory.fromJson(Map<String, dynamic> json) {
    return GcdStory(
      title: _text(json['title']),
      synopsis: _text(json['synopsis']),
      script: _text(json['script']),
      pencils: _text(json['pencils']),
      inks: _text(json['inks']),
      colors: _text(json['colors']),
      letters: _text(json['letters']),
      editing: _text(json['editing']),
      characters: _text(json['characters']),
      partOfIssueStoryArc: _text(json['part_of_issue_story_arc']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (synopsis != null) 'synopsis': synopsis,
        if (script != null) 'script': script,
        if (pencils != null) 'pencils': pencils,
        if (inks != null) 'inks': inks,
        if (colors != null) 'colors': colors,
        if (letters != null) 'letters': letters,
        if (editing != null) 'editing': editing,
        if (characters != null) 'characters': characters,
        if (partOfIssueStoryArc != null)
          'part_of_issue_story_arc': partOfIssueStoryArc,
      };
}

@immutable
class GcdIssue {
  const GcdIssue({
    this.id,
    this.apiUrl,
    this.seriesName,
    this.number,
    this.descriptor,
    this.title,
    this.publisherName,
    this.cover,
    this.synopsis,
    this.stories = const [],
    this.editing,
    this.publicationDate,
    this.price,
    this.variantOf,
  });

  final String? id;
  final String? apiUrl;
  final String? seriesName;
  final String? number;
  final String? descriptor;
  final String? title;
  final String? publisherName;
  final String? cover;
  final String? synopsis;
  final List<GcdStory> stories;
  final String? editing;
  final String? publicationDate;
  final String? price;
  final Object? variantOf;

  factory GcdIssue.fromJson(Map<String, dynamic> json) {
    final rawStories = json['story_set'];
    final stories = <GcdStory>[];
    if (rawStories is List) {
      for (final rawStory in rawStories) {
        if (rawStory is Map) {
          stories.add(GcdStory.fromJson(Map<String, dynamic>.from(rawStory)));
        }
      }
    }

    return GcdIssue(
      id: _text(json['id']),
      apiUrl: _text(json['api_url']),
      seriesName: _text(json['series_name']),
      number: _text(json['number']),
      descriptor: _text(json['descriptor']),
      title: _text(json['title']),
      publisherName:
          _publisherName(json['publisher_name'] ?? json['publisher']),
      cover: _text(json['cover']),
      synopsis: _text(json['synopsis']),
      stories: List.unmodifiable(stories),
      editing: _text(json['editing']),
      publicationDate: _text(json['publication_date']),
      price: _text(json['price']),
      variantOf: json['variant_of'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (apiUrl != null) 'api_url': apiUrl,
        if (seriesName != null) 'series_name': seriesName,
        if (number != null) 'number': number,
        if (descriptor != null) 'descriptor': descriptor,
        if (title != null) 'title': title,
        if (publisherName != null) 'publisher_name': publisherName,
        if (cover != null) 'cover': cover,
        if (synopsis != null) 'synopsis': synopsis,
        if (stories.isNotEmpty)
          'story_set': stories.map((story) => story.toJson()).toList(),
        if (editing != null) 'editing': editing,
        if (publicationDate != null) 'publication_date': publicationDate,
        if (price != null) 'price': price,
        if (variantOf != null) 'variant_of': variantOf,
      };
}

String? _publisherName(Object? value) {
  if (value is Map) {
    return _text(value['name']);
  }
  return _text(value);
}

String? _text(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
