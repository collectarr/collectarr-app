import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

const Object _movieDetailsUnset = Object();

@immutable
final class MovieEntryDetails implements JsonEncodable {
  const MovieEntryDetails({
    this.features,
    this.hdrFormats = const <String>[],
    this.boxSetId,
    this.boxSetName,
    this.region,
    this.packaging,
    this.distributor,
  });

  final String? features;
  final List<String> hdrFormats;
  final String? boxSetId;
  final String? boxSetName;
  final String? region;
  final String? packaging;
  final String? distributor;

  @override
  Map<String, dynamic> toJson() => {
        if (features != null) 'features': features,
        'hdr_formats': hdrFormats,
        if (boxSetId != null) 'box_set_id': boxSetId,
        if (boxSetName != null) 'box_set_name': boxSetName,
        if (region != null) 'region': region,
        if (packaging != null) 'packaging': packaging,
        if (distributor != null) 'distributor': distributor,
      };

  factory MovieEntryDetails.fromJson(Map<String, dynamic> json) =>
      MovieEntryDetails(
        features: json['features'] as String?,
        hdrFormats: _stringList(json['hdr_formats']),
        boxSetId: json['box_set_id'] as String?,
        boxSetName: json['box_set_name'] as String?,
        region: json['region'] as String?,
        packaging: json['packaging'] as String?,
        distributor: json['distributor'] as String?,
      );

  MovieEntryDetails copyWith({
    Object? features = _movieDetailsUnset,
    List<String>? hdrFormats,
    Object? boxSetId = _movieDetailsUnset,
    Object? boxSetName = _movieDetailsUnset,
    Object? region = _movieDetailsUnset,
    Object? packaging = _movieDetailsUnset,
    Object? distributor = _movieDetailsUnset,
  }) =>
      MovieEntryDetails(
        features: identical(features, _movieDetailsUnset)
            ? this.features
            : features as String?,
        hdrFormats: hdrFormats ?? this.hdrFormats,
        boxSetId: identical(boxSetId, _movieDetailsUnset)
            ? this.boxSetId
            : boxSetId as String?,
        boxSetName: identical(boxSetName, _movieDetailsUnset)
            ? this.boxSetName
            : boxSetName as String?,
        region: identical(region, _movieDetailsUnset)
            ? this.region
            : region as String?,
        packaging: identical(packaging, _movieDetailsUnset)
            ? this.packaging
            : packaging as String?,
        distributor: identical(distributor, _movieDetailsUnset)
            ? this.distributor
            : distributor as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieEntryDetails &&
          features == other.features &&
          listEquals(hdrFormats, other.hdrFormats) &&
          boxSetId == other.boxSetId &&
          boxSetName == other.boxSetName &&
          region == other.region &&
          packaging == other.packaging &&
          distributor == other.distributor;

  @override
  int get hashCode => Object.hash(
        features,
        Object.hashAll(hdrFormats),
        boxSetId,
        boxSetName,
        region,
        packaging,
        distributor,
      );
}

List<String> _stringList(Object? value) => value is List
    ? value.whereType<String>().toList(growable: false)
    : const <String>[];
