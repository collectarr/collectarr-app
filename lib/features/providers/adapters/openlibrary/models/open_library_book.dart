import 'package:flutter/foundation.dart';

@immutable
class OpenLibraryWorkReference {
  const OpenLibraryWorkReference({this.key});

  final String? key;

  factory OpenLibraryWorkReference.fromJson(Map<String, dynamic> json) {
    return OpenLibraryWorkReference(key: _text(json['key']));
  }

  Map<String, dynamic> toJson() => {
        if (key != null) 'key': key,
      };
}

@immutable
class OpenLibrarySearchDoc {
  const OpenLibrarySearchDoc({
    this.key,
    this.title,
    this.authorNames = const [],
    this.firstPublishYear,
    this.editionKeys = const [],
    this.isbn = const [],
    this.publishers = const [],
    this.coverId,
  });

  final String? key;
  final String? title;
  final List<String> authorNames;
  final int? firstPublishYear;
  final List<String> editionKeys;
  final List<String> isbn;
  final List<String> publishers;
  final int? coverId;

  factory OpenLibrarySearchDoc.fromJson(Map<String, dynamic> json) {
    return OpenLibrarySearchDoc(
      key: _text(json['key']),
      title: _text(json['title']),
      authorNames: _textList(json['author_name']),
      firstPublishYear: _int(json['first_publish_year']),
      editionKeys: _textList(json['edition_key']),
      isbn: _textList(json['isbn']),
      publishers: _textList(json['publisher']),
      coverId: _int(json['cover_i']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (key != null) 'key': key,
        if (title != null) 'title': title,
        if (authorNames.isNotEmpty) 'author_name': authorNames,
        if (firstPublishYear != null) 'first_publish_year': firstPublishYear,
        if (editionKeys.isNotEmpty) 'edition_key': editionKeys,
        if (isbn.isNotEmpty) 'isbn': isbn,
        if (publishers.isNotEmpty) 'publisher': publishers,
        if (coverId != null) 'cover_i': coverId,
      };
}

@immutable
class OpenLibraryWork {
  const OpenLibraryWork({
    this.key,
    this.title,
    this.description,
    this.subjects = const [],
  });

  final String? key;
  final String? title;
  final String? description;
  final List<String> subjects;

  factory OpenLibraryWork.fromJson(Map<String, dynamic> json) {
    return OpenLibraryWork(
      key: _text(json['key']),
      title: _text(json['title']),
      description: _description(json['description']),
      subjects: _textList(json['subjects']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (key != null) 'key': key,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (subjects.isNotEmpty) 'subjects': subjects,
      };
}

@immutable
class OpenLibraryEdition {
  const OpenLibraryEdition({
    this.key,
    this.ocaid,
    this.title,
    this.subtitle,
    this.description,
    this.publishDate,
    this.numberOfPages,
    this.publishers = const [],
    this.isbn13 = const [],
    this.isbn10 = const [],
    this.covers = const [],
    this.works = const [],
  });

  final String? key;
  final String? ocaid;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? publishDate;
  final int? numberOfPages;
  final List<String> publishers;
  final List<String> isbn13;
  final List<String> isbn10;
  final List<int> covers;
  final List<OpenLibraryWorkReference> works;

  factory OpenLibraryEdition.fromJson(Map<String, dynamic> json) {
    return OpenLibraryEdition(
      key: _text(json['key']),
      ocaid: _text(json['ocaid']),
      title: _text(json['title']),
      subtitle: _text(json['subtitle']),
      description: _description(json['description']),
      publishDate: _text(json['publish_date']),
      numberOfPages: _int(json['number_of_pages']),
      publishers: _textList(json['publishers']),
      isbn13: _textList(json['isbn_13']),
      isbn10: _textList(json['isbn_10']),
      covers: _intList(json['covers']),
      works: _workReferences(json['works']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (key != null) 'key': key,
        if (ocaid != null) 'ocaid': ocaid,
        if (title != null) 'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (description != null) 'description': description,
        if (publishDate != null) 'publish_date': publishDate,
        if (numberOfPages != null) 'number_of_pages': numberOfPages,
        if (publishers.isNotEmpty) 'publishers': publishers,
        if (isbn13.isNotEmpty) 'isbn_13': isbn13,
        if (isbn10.isNotEmpty) 'isbn_10': isbn10,
        if (covers.isNotEmpty) 'covers': covers,
        if (works.isNotEmpty)
          'works': works.map((work) => work.toJson()).toList(),
      };
}

List<String> _textList(Object? value) {
  if (value is! List) {
    final text = _text(value);
    return text == null ? const [] : [text];
  }
  return List.unmodifiable([
    for (final item in value)
      if (_text(item) case final text?) text,
  ]);
}

List<int> _intList(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (_int(item) case final parsed?) parsed,
  ]);
}

List<OpenLibraryWorkReference> _workReferences(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map)
        OpenLibraryWorkReference.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

String? _description(Object? value) {
  if (value is Map) return _text(value['value']);
  return _text(value);
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
