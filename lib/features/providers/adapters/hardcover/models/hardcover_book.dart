import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class HardcoverImage {
  const HardcoverImage({this.url});

  final String? url;

  factory HardcoverImage.fromJson(Object? value) {
    if (value is! Map) return const HardcoverImage();
    return HardcoverImage(url: _text(value['url']));
  }

  Map<String, dynamic> toJson() => {
        if (url != null) 'url': url,
      };
}

@immutable
class HardcoverAuthor {
  const HardcoverAuthor({this.name, this.image});

  final String? name;
  final HardcoverImage? image;

  factory HardcoverAuthor.fromJson(Map<String, dynamic> json) {
    return HardcoverAuthor(
      name: _text(json['name']),
      image:
          json['image'] is Map ? HardcoverImage.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (image != null) 'image': image!.toJson(),
      };
}

@immutable
class HardcoverContribution {
  const HardcoverContribution({this.author, this.contributionType});

  final HardcoverAuthor? author;
  final String? contributionType;

  factory HardcoverContribution.fromJson(Map<String, dynamic> json) {
    return HardcoverContribution(
      author: json['author'] is Map
          ? HardcoverAuthor.fromJson(
              Map<String, dynamic>.from(json['author'] as Map),
            )
          : null,
      contributionType: _text(json['contribution_type']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (author != null) 'author': author!.toJson(),
        if (contributionType != null) 'contribution_type': contributionType,
      };
}

@immutable
class HardcoverSeries {
  const HardcoverSeries({this.id, this.name, this.slug});

  final int? id;
  final String? name;
  final String? slug;

  factory HardcoverSeries.fromJson(Map<String, dynamic> json) {
    return HardcoverSeries(
      id: _int(json['id']),
      name: _text(json['name']),
      slug: _text(json['slug']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (slug != null) 'slug': slug,
      };
}

@immutable
class HardcoverBookSeries {
  const HardcoverBookSeries({this.series, this.position});

  final HardcoverSeries? series;
  final num? position;

  factory HardcoverBookSeries.fromJson(Map<String, dynamic> json) {
    return HardcoverBookSeries(
      series: json['series'] is Map
          ? HardcoverSeries.fromJson(
              Map<String, dynamic>.from(json['series'] as Map),
            )
          : null,
      position: _number(json['position']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (series != null) 'series': series!.toJson(),
        if (position != null) 'position': position,
      };
}

@immutable
class HardcoverPublisher {
  const HardcoverPublisher({this.name});

  final String? name;

  factory HardcoverPublisher.fromJson(Map<String, dynamic> json) {
    return HardcoverPublisher(name: _text(json['name']));
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
      };
}

@immutable
class HardcoverEdition {
  const HardcoverEdition({
    this.isbn10,
    this.isbn13,
    this.pages,
    this.releaseDate,
    this.editionFormat,
    this.image,
    this.publisher,
  });

  final String? isbn10;
  final String? isbn13;
  final int? pages;
  final String? releaseDate;
  final String? editionFormat;
  final HardcoverImage? image;
  final HardcoverPublisher? publisher;

  factory HardcoverEdition.fromJson(Map<String, dynamic> json) {
    return HardcoverEdition(
      isbn10: _text(json['isbn_10']),
      isbn13: _text(json['isbn_13']),
      pages: _int(json['pages']),
      releaseDate: _text(json['release_date']),
      editionFormat: _text(json['edition_format']),
      image:
          json['image'] is Map ? HardcoverImage.fromJson(json['image']) : null,
      publisher: json['publisher'] is Map
          ? HardcoverPublisher.fromJson(
              Map<String, dynamic>.from(json['publisher'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (isbn10 != null) 'isbn_10': isbn10,
        if (isbn13 != null) 'isbn_13': isbn13,
        if (pages != null) 'pages': pages,
        if (releaseDate != null) 'release_date': releaseDate,
        if (editionFormat != null) 'edition_format': editionFormat,
        if (image != null) 'image': image!.toJson(),
        if (publisher != null) 'publisher': publisher!.toJson(),
      };
}

@immutable
class HardcoverTagging {
  const HardcoverTagging({this.name});

  final String? name;

  factory HardcoverTagging.fromJson(Map<String, dynamic> json) {
    final tag = json['tag'];
    return HardcoverTagging(
      name: tag is Map ? _text(tag['tag']) : _text(tag),
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'tag': {'tag': name},
      };
}

@immutable
class HardcoverBook {
  const HardcoverBook({
    this.id,
    this.title,
    this.subtitle,
    this.slug,
    this.description,
    this.pages,
    this.releaseDate,
    this.contributions = const [],
    this.bookSeries = const [],
    this.editions = const [],
    this.image,
    this.taggings = const [],
  });

  final int? id;
  final String? title;
  final String? subtitle;
  final String? slug;
  final String? description;
  final int? pages;
  final String? releaseDate;
  final List<HardcoverContribution> contributions;
  final List<HardcoverBookSeries> bookSeries;
  final List<HardcoverEdition> editions;
  final HardcoverImage? image;
  final List<HardcoverTagging> taggings;

  factory HardcoverBook.fromJson(Map<String, dynamic> json) {
    return HardcoverBook(
      id: _int(json['id']),
      title: _text(json['title']),
      subtitle: _text(json['subtitle']),
      slug: _text(json['slug']),
      description: _text(json['description']),
      pages: _int(json['pages']),
      releaseDate: _text(json['release_date']),
      contributions:
          _listOf(json['contributions'], HardcoverContribution.fromJson),
      bookSeries: _listOf(json['book_series'], HardcoverBookSeries.fromJson),
      editions: _listOf(json['editions'], HardcoverEdition.fromJson),
      image:
          json['image'] is Map ? HardcoverImage.fromJson(json['image']) : null,
      taggings: _listOf(json['taggings'], HardcoverTagging.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (slug != null) 'slug': slug,
        if (description != null) 'description': description,
        if (pages != null) 'pages': pages,
        if (releaseDate != null) 'release_date': releaseDate,
        if (contributions.isNotEmpty)
          'contributions': contributions
              .map((contribution) => contribution.toJson())
              .toList(),
        if (bookSeries.isNotEmpty)
          'book_series': bookSeries.map((series) => series.toJson()).toList(),
        if (editions.isNotEmpty)
          'editions': editions.map((edition) => edition.toJson()).toList(),
        if (image != null) 'image': image!.toJson(),
        if (taggings.isNotEmpty)
          'taggings': taggings.map((tagging) => tagging.toJson()).toList(),
      };
}

@immutable
class HardcoverSearchDocument {
  const HardcoverSearchDocument({
    this.id,
    this.title,
    this.authorNames = const [],
    this.featuredSeries,
    this.releaseYear,
    this.image,
  });

  final int? id;
  final String? title;
  final List<String> authorNames;
  final HardcoverSeries? featuredSeries;
  final String? releaseYear;
  final HardcoverImage? image;

  factory HardcoverSearchDocument.fromJson(Map<String, dynamic> json) {
    return HardcoverSearchDocument(
      id: _int(json['id']),
      title: _text(json['title']),
      authorNames: _textList(json['author_names']),
      featuredSeries: json['featured_series'] is Map
          ? HardcoverSeries.fromJson(
              Map<String, dynamic>.from(json['featured_series'] as Map),
            )
          : null,
      releaseYear: _text(json['release_year']),
      image:
          json['image'] is Map ? HardcoverImage.fromJson(json['image']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (title != null) 'title': title,
        if (authorNames.isNotEmpty) 'author_names': authorNames,
        if (featuredSeries != null) 'featured_series': featuredSeries!.toJson(),
        if (releaseYear != null) 'release_year': releaseYear,
        if (image != null) 'image': image!.toJson(),
      };
}

@immutable
class HardcoverSearchHit {
  const HardcoverSearchHit({required this.document});

  final HardcoverSearchDocument document;

  factory HardcoverSearchHit.fromJson(Map<String, dynamic> json) {
    final document = json['document'];
    return HardcoverSearchHit(
      document: HardcoverSearchDocument.fromJson(
        document is Map ? Map<String, dynamic>.from(document) : json,
      ),
    );
  }
}

List<HardcoverSearchHit> decodeHardcoverSearchHits(Object? value) {
  Object? decoded = value;
  if (decoded is String) {
    try {
      decoded = jsonDecode(decoded);
    } catch (_) {
      return const [];
    }
  }
  if (decoded is! List) return const [];
  return List.unmodifiable([
    for (final item in decoded)
      if (item is Map)
        HardcoverSearchHit.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<T> _listOf<T>(Object? value, T Function(Map<String, dynamic>) parse) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map) parse(Map<String, dynamic>.from(item)),
  ]);
}

List<String> _textList(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (_text(item) case final text?) text,
  ]);
}

int? _int(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

num? _number(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString().trim() ?? '');
}

String? _text(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
