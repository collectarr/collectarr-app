import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ComicStoryArc implements JsonEncodable {
  const ComicStoryArc({
    this.id,
    this.name,
    this.description,
    this.publisher,
    this.startDate,
    this.endDate,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? publisher;
  final PartialDate? startDate;
  final PartialDate? endDate;

  factory ComicStoryArc.fromValue(Object value) {
    if (value is String) return ComicStoryArc(name: value);
    if (value is! Map) {
      throw const FormatException(
        'Comic story arcs must be strings or objects.',
      );
    }
    final json = Map<String, dynamic>.from(value);
    return ComicStoryArc(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      publisher: json['publisher'] as String?,
      startDate: PartialDate.tryParse(json['start_date']),
      endDate: PartialDate.tryParse(json['end_date']),
    );
  }

  ComicStoryArc copyWith({String? name}) => ComicStoryArc(
        id: id,
        name: name ?? this.name,
        description: description,
        publisher: publisher,
        startDate: startDate,
        endDate: endDate,
      );

  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (publisher != null) 'publisher': publisher,
        if (startDate != null) 'start_date': startDate!.toJson(),
        if (endDate != null) 'end_date': endDate!.toJson(),
      };

  Object toJsonValue() => id == null &&
          description == null &&
          publisher == null &&
          startDate == null &&
          endDate == null
      ? name ?? ''
      : toJson();
}
