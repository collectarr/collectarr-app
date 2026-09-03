import 'package:flutter/foundation.dart';

@immutable
class ComicVineImage {
  const ComicVineImage({
    this.superUrl,
    this.mediumUrl,
    this.scaleLarge,
    this.originalUrl,
    this.squareMini,
    this.iconUrl,
    this.thumbUrl,
    this.caption,
  });

  final String? superUrl;
  final String? mediumUrl;
  final String? scaleLarge;
  final String? originalUrl;
  final String? squareMini;
  final String? iconUrl;
  final String? thumbUrl;
  final String? caption;

  factory ComicVineImage.fromJson(Map<String, dynamic> json) {
    return ComicVineImage(
      superUrl: _text(json['super_url']),
      mediumUrl: _text(json['medium_url']),
      scaleLarge: _text(json['scale_large']),
      originalUrl: _text(json['original_url']),
      squareMini: _text(json['square_mini']),
      iconUrl: _text(json['icon_url']),
      thumbUrl: _text(json['thumb_url']),
      caption: _text(json['caption']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (superUrl != null) 'super_url': superUrl,
        if (mediumUrl != null) 'medium_url': mediumUrl,
        if (scaleLarge != null) 'scale_large': scaleLarge,
        if (originalUrl != null) 'original_url': originalUrl,
        if (squareMini != null) 'square_mini': squareMini,
        if (iconUrl != null) 'icon_url': iconUrl,
        if (thumbUrl != null) 'thumb_url': thumbUrl,
        if (caption != null) 'caption': caption,
      };
}

@immutable
class ComicVinePerson {
  const ComicVinePerson({
    this.name,
    this.role,
  });

  final String? name;
  final String? role;

  factory ComicVinePerson.fromJson(Map<String, dynamic> json) {
    return ComicVinePerson(
      name: _text(json['name']),
      role: _text(json['role']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (role != null) 'role': role,
      };
}

@immutable
class ComicVineVolume {
  const ComicVineVolume({
    this.name,
    this.startYear,
    this.publisherName,
  });

  final String? name;
  final int? startYear;
  final String? publisherName;

  factory ComicVineVolume.fromJson(Map<String, dynamic> json) {
    final publisher = json['publisher'];
    return ComicVineVolume(
      name: _text(json['name']),
      startYear: _int(json['start_year']),
      publisherName:
          publisher is Map ? _text(publisher['name']) : _text(publisher),
    );
  }

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (startYear != null) 'start_year': startYear,
        if (publisherName != null)
          'publisher': <String, dynamic>{'name': publisherName},
      };
}

@immutable
class ComicVineIssue {
  const ComicVineIssue({
    this.id,
    this.apiDetailUrl,
    this.siteDetailUrl,
    this.mediaType,
    this.name,
    this.issueNumber,
    this.deck,
    this.description,
    this.volume,
    this.image,
    this.personCredits = const [],
    this.associatedImages = const [],
  });

  final String? id;
  final String? apiDetailUrl;
  final String? siteDetailUrl;
  final String? mediaType;
  final String? name;
  final String? issueNumber;
  final String? deck;
  final String? description;
  final ComicVineVolume? volume;
  final ComicVineImage? image;
  final List<ComicVinePerson> personCredits;
  final List<ComicVineImage> associatedImages;

  factory ComicVineIssue.fromJson(Map<String, dynamic> json) {
    final rawVolume = json['volume'];
    final rawImage = json['image'];
    final rawPeople = json['person_credits'];
    final rawAssociatedImages = json['associated_images'];
    final people = <ComicVinePerson>[];
    final associatedImages = <ComicVineImage>[];

    if (rawPeople is List) {
      for (final person in rawPeople) {
        if (person is Map) {
          people.add(
            ComicVinePerson.fromJson(Map<String, dynamic>.from(person)),
          );
        }
      }
    }
    if (rawAssociatedImages is List) {
      for (final image in rawAssociatedImages) {
        if (image is Map) {
          associatedImages.add(
            ComicVineImage.fromJson(Map<String, dynamic>.from(image)),
          );
        }
      }
    }

    return ComicVineIssue(
      id: _text(json['id']),
      apiDetailUrl: _text(json['api_detail_url']),
      siteDetailUrl: _text(json['site_detail_url']),
      mediaType: _text(json['media_type']),
      name: _text(json['name']),
      issueNumber: _text(json['issue_number']),
      deck: _text(json['deck']),
      description: _text(json['description']),
      volume: rawVolume is Map
          ? ComicVineVolume.fromJson(Map<String, dynamic>.from(rawVolume))
          : null,
      image: rawImage is Map
          ? ComicVineImage.fromJson(Map<String, dynamic>.from(rawImage))
          : null,
      personCredits: List.unmodifiable(people),
      associatedImages: List.unmodifiable(associatedImages),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (apiDetailUrl != null) 'api_detail_url': apiDetailUrl,
        if (siteDetailUrl != null) 'site_detail_url': siteDetailUrl,
        if (mediaType != null) 'media_type': mediaType,
        if (name != null) 'name': name,
        if (issueNumber != null) 'issue_number': issueNumber,
        if (deck != null) 'deck': deck,
        if (description != null) 'description': description,
        if (volume != null) 'volume': volume!.toJson(),
        if (image != null) 'image': image!.toJson(),
        if (personCredits.isNotEmpty)
          'person_credits':
              personCredits.map((person) => person.toJson()).toList(),
        if (associatedImages.isNotEmpty)
          'associated_images':
              associatedImages.map((image) => image.toJson()).toList(),
      };
}

String? _text(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

int? _int(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}
