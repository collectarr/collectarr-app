import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

const Object _tvDetailsUnset = Object();

@immutable
final class TvEntryDetails implements JsonEncodable {
  const TvEntryDetails({
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

  factory TvEntryDetails.fromJson(Map<String, dynamic> json) =>
      TvEntryDetails(
        features: json['features'] as String?,
        hdrFormats: _stringList(json['hdr_formats']),
        boxSetId: json['box_set_id'] as String?,
        boxSetName: json['box_set_name'] as String?,
        region: json['region'] as String?,
        packaging: json['packaging'] as String?,
        distributor: json['distributor'] as String?,
      );

  TvEntryDetails copyWith({
    Object? features = _tvDetailsUnset,
    List<String>? hdrFormats,
    Object? boxSetId = _tvDetailsUnset,
    Object? boxSetName = _tvDetailsUnset,
    Object? region = _tvDetailsUnset,
    Object? packaging = _tvDetailsUnset,
    Object? distributor = _tvDetailsUnset,
  }) =>
      TvEntryDetails(
        features: identical(features, _tvDetailsUnset)
            ? this.features
            : features as String?,
        hdrFormats: hdrFormats ?? this.hdrFormats,
        boxSetId: identical(boxSetId, _tvDetailsUnset)
            ? this.boxSetId
            : boxSetId as String?,
        boxSetName: identical(boxSetName, _tvDetailsUnset)
            ? this.boxSetName
            : boxSetName as String?,
        region: identical(region, _tvDetailsUnset)
            ? this.region
            : region as String?,
        packaging: identical(packaging, _tvDetailsUnset)
            ? this.packaging
            : packaging as String?,
        distributor: identical(distributor, _tvDetailsUnset)
            ? this.distributor
            : distributor as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TvEntryDetails &&
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
