import 'package:flutter/foundation.dart';

@immutable
class AniListTitle {
  const AniListTitle({this.romaji, this.english, this.native});

  final String? romaji;
  final String? english;
  final String? native;

  factory AniListTitle.fromJson(Map<String, dynamic> json) {
    return AniListTitle(
      romaji: _text(json['romaji']),
      english: _text(json['english']),
      native: _text(json['native']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (romaji != null) 'romaji': romaji,
        if (english != null) 'english': english,
        if (native != null) 'native': native,
      };
}

@immutable
class AniListDate {
  const AniListDate({this.year, this.month, this.day});

  final int? year;
  final int? month;
  final int? day;

  factory AniListDate.fromJson(Map<String, dynamic> json) {
    return AniListDate(
      year: _int(json['year']),
      month: _int(json['month']),
      day: _int(json['day']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (year != null) 'year': year,
        if (month != null) 'month': month,
        if (day != null) 'day': day,
      };
}

@immutable
class AniListCoverImage {
  const AniListCoverImage({this.large, this.medium});

  final String? large;
  final String? medium;

  factory AniListCoverImage.fromJson(Map<String, dynamic> json) {
    return AniListCoverImage(
      large: _text(json['large']),
      medium: _text(json['medium']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (large != null) 'large': large,
        if (medium != null) 'medium': medium,
      };
}

@immutable
class AniListTrailer {
  const AniListTrailer({this.id, this.site, this.thumbnail});

  final String? id;
  final String? site;
  final String? thumbnail;

  factory AniListTrailer.fromJson(Map<String, dynamic> json) {
    return AniListTrailer(
      id: _text(json['id']),
      site: _text(json['site']),
      thumbnail: _text(json['thumbnail']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (site != null) 'site': site,
        if (thumbnail != null) 'thumbnail': thumbnail,
      };
}

@immutable
class AniListExternalLink {
  const AniListExternalLink({this.site, this.url});

  final String? site;
  final String? url;

  factory AniListExternalLink.fromJson(Map<String, dynamic> json) {
    return AniListExternalLink(
      site: _text(json['site']),
      url: _text(json['url']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (site != null) 'site': site,
        if (url != null) 'url': url,
      };
}

@immutable
class AniListStaffCredit {
  const AniListStaffCredit({this.role, this.name, this.siteUrl});

  final String? role;
  final String? name;
  final String? siteUrl;

  factory AniListStaffCredit.fromJson(Map<String, dynamic> json) {
    final node = json['node'];
    final nodeMap = node is Map ? Map<String, dynamic>.from(node) : null;
    final name = nodeMap?['name'];
    return AniListStaffCredit(
      role: _text(json['role']),
      name: name is Map ? _text(name['full']) : null,
      siteUrl: _text(nodeMap?['siteUrl']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (role != null) 'role': role,
        if (name != null || siteUrl != null)
          'node': {
            if (name != null) 'name': {'full': name},
            if (siteUrl != null) 'siteUrl': siteUrl,
          },
      };
}

@immutable
class AniListCharacterCredit {
  const AniListCharacterCredit({
    this.role,
    this.name,
    this.siteUrl,
    this.image,
  });

  final String? role;
  final String? name;
  final String? siteUrl;
  final AniListCoverImage? image;

  factory AniListCharacterCredit.fromJson(Map<String, dynamic> json) {
    final node = json['node'];
    final nodeMap = node is Map ? Map<String, dynamic>.from(node) : null;
    final name = nodeMap?['name'];
    final image = nodeMap?['image'];
    return AniListCharacterCredit(
      role: _text(json['role']),
      name: name is Map ? _text(name['full']) : null,
      siteUrl: _text(nodeMap?['siteUrl']),
      image: image is Map
          ? AniListCoverImage.fromJson(Map<String, dynamic>.from(image))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (role != null) 'role': role,
        if (name != null || siteUrl != null || image != null)
          'node': {
            if (name != null) 'name': {'full': name},
            if (siteUrl != null) 'siteUrl': siteUrl,
            if (image != null) 'image': image!.toJson(),
          },
      };
}

@immutable
class AniListRelatedMedia {
  const AniListRelatedMedia({
    this.id,
    this.type,
    this.format,
    this.title,
    this.startDate,
    this.coverImage,
  });

  final int? id;
  final String? type;
  final String? format;
  final AniListTitle? title;
  final AniListDate? startDate;
  final AniListCoverImage? coverImage;

  factory AniListRelatedMedia.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final startDate = json['startDate'];
    final coverImage = json['coverImage'];
    return AniListRelatedMedia(
      id: _int(json['id']),
      type: _text(json['type']),
      format: _text(json['format']),
      title: title is Map
          ? AniListTitle.fromJson(Map<String, dynamic>.from(title))
          : null,
      startDate: startDate is Map
          ? AniListDate.fromJson(Map<String, dynamic>.from(startDate))
          : null,
      coverImage: coverImage is Map
          ? AniListCoverImage.fromJson(Map<String, dynamic>.from(coverImage))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (type != null) 'type': type,
        if (format != null) 'format': format,
        if (title != null) 'title': title!.toJson(),
        if (startDate != null) 'startDate': startDate!.toJson(),
        if (coverImage != null) 'coverImage': coverImage!.toJson(),
      };
}

@immutable
class AniListRelation {
  const AniListRelation({this.relationType, this.media});

  final String? relationType;
  final AniListRelatedMedia? media;

  factory AniListRelation.fromJson(Map<String, dynamic> json) {
    final node = json['node'];
    return AniListRelation(
      relationType: _text(json['relationType']),
      media: node is Map
          ? AniListRelatedMedia.fromJson(Map<String, dynamic>.from(node))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (relationType != null) 'relationType': relationType,
        if (media != null) 'node': media!.toJson(),
      };
}

@immutable
class AniListMedia {
  const AniListMedia({
    this.id,
    this.idMal,
    this.siteUrl,
    this.type,
    this.title,
    this.description,
    this.format,
    this.status,
    this.averageScore,
    this.chapters,
    this.volumes,
    this.episodes,
    this.duration,
    this.startDate,
    this.coverImage,
    this.genres = const [],
    this.trailer,
    this.externalLinks = const [],
    this.staff = const [],
    this.characters = const [],
    this.relations = const [],
  });

  final int? id;
  final int? idMal;
  final String? siteUrl;
  final String? type;
  final AniListTitle? title;
  final String? description;
  final String? format;
  final String? status;
  final num? averageScore;
  final int? chapters;
  final int? volumes;
  final int? episodes;
  final int? duration;
  final AniListDate? startDate;
  final AniListCoverImage? coverImage;
  final List<String> genres;
  final AniListTrailer? trailer;
  final List<AniListExternalLink> externalLinks;
  final List<AniListStaffCredit> staff;
  final List<AniListCharacterCredit> characters;
  final List<AniListRelation> relations;

  factory AniListMedia.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final startDate = json['startDate'];
    final coverImage = json['coverImage'];
    final trailer = json['trailer'];
    return AniListMedia(
      id: _int(json['id']),
      idMal: _int(json['idMal']),
      siteUrl: _text(json['siteUrl']),
      type: _text(json['type']),
      title: title is Map
          ? AniListTitle.fromJson(Map<String, dynamic>.from(title))
          : null,
      description: _text(json['description']),
      format: _text(json['format']),
      status: _text(json['status']),
      averageScore: _number(json['averageScore']),
      chapters: _int(json['chapters']),
      volumes: _int(json['volumes']),
      episodes: _int(json['episodes']),
      duration: _int(json['duration']),
      startDate: startDate is Map
          ? AniListDate.fromJson(Map<String, dynamic>.from(startDate))
          : null,
      coverImage: coverImage is Map
          ? AniListCoverImage.fromJson(Map<String, dynamic>.from(coverImage))
          : null,
      genres: _textList(json['genres']),
      trailer: trailer is Map
          ? AniListTrailer.fromJson(Map<String, dynamic>.from(trailer))
          : null,
      externalLinks: _externalLinks(json['externalLinks']),
      staff: _staff(json['staff']),
      characters: _characters(json['characters']),
      relations: _relations(json['relations']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (idMal != null) 'idMal': idMal,
        if (siteUrl != null) 'siteUrl': siteUrl,
        if (type != null) 'type': type,
        if (title != null) 'title': title!.toJson(),
        if (description != null) 'description': description,
        if (format != null) 'format': format,
        if (status != null) 'status': status,
        if (averageScore != null) 'averageScore': averageScore,
        if (chapters != null) 'chapters': chapters,
        if (volumes != null) 'volumes': volumes,
        if (episodes != null) 'episodes': episodes,
        if (duration != null) 'duration': duration,
        if (startDate != null) 'startDate': startDate!.toJson(),
        if (coverImage != null) 'coverImage': coverImage!.toJson(),
        if (genres.isNotEmpty) 'genres': genres,
        if (trailer != null) 'trailer': trailer!.toJson(),
        if (externalLinks.isNotEmpty)
          'externalLinks': externalLinks.map((link) => link.toJson()).toList(),
        if (staff.isNotEmpty)
          'staff': {'edges': staff.map((credit) => credit.toJson()).toList()},
        if (characters.isNotEmpty)
          'characters': {
            'edges': characters.map((credit) => credit.toJson()).toList(),
          },
        if (relations.isNotEmpty)
          'relations': {
            'edges': relations.map((relation) => relation.toJson()).toList(),
          },
      };
}

List<String> _textList(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (_text(item) case final text?) text,
  ]);
}

List<AniListExternalLink> _externalLinks(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map)
        AniListExternalLink.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<AniListStaffCredit> _staff(Object? value) {
  return _edgeList(value, AniListStaffCredit.fromJson);
}

List<AniListCharacterCredit> _characters(Object? value) {
  return _edgeList(value, AniListCharacterCredit.fromJson);
}

List<AniListRelation> _relations(Object? value) {
  return _edgeList(value, AniListRelation.fromJson);
}

List<T> _edgeList<T>(Object? value, T Function(Map<String, dynamic>) parse) {
  if (value is! Map) return const [];
  final edges = value['edges'];
  if (edges is! List) return const [];
  return List.unmodifiable([
    for (final item in edges)
      if (item is Map) parse(Map<String, dynamic>.from(item)),
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
