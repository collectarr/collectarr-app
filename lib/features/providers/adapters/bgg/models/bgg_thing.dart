import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

@immutable
class BggName {
  const BggName({this.type, this.sortIndex, this.value});

  final String? type;
  final String? sortIndex;
  final String? value;

  factory BggName.fromJson(Map<String, dynamic> json) {
    return BggName(
      type: _text(json['type']),
      sortIndex: _text(json['sortindex']),
      value: _text(json['value']),
    );
  }

  factory BggName.fromXml(XmlElement element) {
    return BggName(
      type: element.getAttribute('type'),
      sortIndex: element.getAttribute('sortindex'),
      value: element.getAttribute('value'),
    );
  }

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (sortIndex != null) 'sortindex': sortIndex,
        if (value != null) 'value': value,
      };
}

@immutable
class BggLink {
  const BggLink({this.type, this.id, this.value});

  final String? type;
  final String? id;
  final String? value;

  factory BggLink.fromJson(Map<String, dynamic> json) {
    return BggLink(
      type: _text(json['type']),
      id: _text(json['id']),
      value: _text(json['value']),
    );
  }

  factory BggLink.fromXml(XmlElement element) {
    return BggLink(
      type: element.getAttribute('type'),
      id: element.getAttribute('id'),
      value: element.getAttribute('value'),
    );
  }

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (id != null) 'id': id,
        if (value != null) 'value': value,
      };
}

@immutable
class BggThing {
  const BggThing({
    this.id,
    this.type,
    this.names = const [],
    this.description,
    this.yearPublished,
    this.minPlayers,
    this.maxPlayers,
    this.playingTime,
    this.minPlayingTime,
    this.maxPlayingTime,
    this.minAge,
    this.image,
    this.thumbnail,
    this.links = const [],
  });

  final String? id;
  final String? type;
  final List<BggName> names;
  final String? description;
  final int? yearPublished;
  final int? minPlayers;
  final int? maxPlayers;
  final int? playingTime;
  final int? minPlayingTime;
  final int? maxPlayingTime;
  final int? minAge;
  final String? image;
  final String? thumbnail;
  final List<BggLink> links;

  factory BggThing.fromJson(Map<String, dynamic> json) {
    return BggThing(
      id: _text(json['id']),
      type: _text(json['type']),
      names: _names(json['names']),
      description: _text(json['description']),
      yearPublished: _int(json['yearpublished']),
      minPlayers: _int(json['minplayers']),
      maxPlayers: _int(json['maxplayers']),
      playingTime: _int(json['playingtime']),
      minPlayingTime: _int(json['minplaytime']),
      maxPlayingTime: _int(json['maxplaytime']),
      minAge: _int(json['minage']),
      image: _text(json['image']),
      thumbnail: _text(json['thumbnail']),
      links: _links(json['links']),
    );
  }

  factory BggThing.fromXml(XmlElement element) {
    return BggThing(
      id: element.getAttribute('id'),
      type: element.getAttribute('type'),
      names: List.unmodifiable(
        element.findElements('name').map(BggName.fromXml),
      ),
      description:
          _text(element.findElements('description').firstOrNull?.innerText),
      yearPublished: _elementInt(element, 'yearpublished'),
      minPlayers: _elementInt(element, 'minplayers'),
      maxPlayers: _elementInt(element, 'maxplayers'),
      playingTime: _elementInt(element, 'playingtime'),
      minPlayingTime: _elementInt(element, 'minplaytime'),
      maxPlayingTime: _elementInt(element, 'maxplaytime'),
      minAge: _elementInt(element, 'minage'),
      image: _text(element.findElements('image').firstOrNull?.innerText),
      thumbnail:
          _text(element.findElements('thumbnail').firstOrNull?.innerText),
      links: List.unmodifiable(
        element.findElements('link').map(BggLink.fromXml),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (type != null) 'type': type,
        if (names.isNotEmpty)
          'names': names.map((name) => name.toJson()).toList(),
        if (description != null) 'description': description,
        if (yearPublished != null) 'yearpublished': yearPublished,
        if (minPlayers != null) 'minplayers': minPlayers,
        if (maxPlayers != null) 'maxplayers': maxPlayers,
        if (playingTime != null) 'playingtime': playingTime,
        if (minPlayingTime != null) 'minplaytime': minPlayingTime,
        if (maxPlayingTime != null) 'maxplaytime': maxPlayingTime,
        if (minAge != null) 'minage': minAge,
        if (image != null) 'image': image,
        if (thumbnail != null) 'thumbnail': thumbnail,
        if (links.isNotEmpty)
          'links': links.map((link) => link.toJson()).toList(),
      };
}

List<BggName> _names(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map) BggName.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

List<BggLink> _links(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable([
    for (final item in value)
      if (item is Map) BggLink.fromJson(Map<String, dynamic>.from(item)),
  ]);
}

int? _elementInt(XmlElement parent, String name) {
  return _int(parent.findElements(name).firstOrNull?.getAttribute('value'));
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
