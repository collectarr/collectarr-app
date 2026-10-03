import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:flutter/foundation.dart';

const Object _animeDetailsUnset = Object();

@immutable
final class AnimeEntryDetails implements JsonEncodable {
  const AnimeEntryDetails({
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

  factory AnimeEntryDetails.fromJson(Map<String, dynamic> json) =>
      AnimeEntryDetails(
        features: json['features'] as String?,
        hdrFormats: _stringList(json['hdr_formats']),
        boxSetId: json['box_set_id'] as String?,
        boxSetName: json['box_set_name'] as String?,
        region: json['region'] as String?,
        packaging: json['packaging'] as String?,
        distributor: json['distributor'] as String?,
      );

  AnimeEntryDetails copyWith({
    Object? features = _animeDetailsUnset,
    List<String>? hdrFormats,
    Object? boxSetId = _animeDetailsUnset,
    Object? boxSetName = _animeDetailsUnset,
    Object? region = _animeDetailsUnset,
    Object? packaging = _animeDetailsUnset,
    Object? distributor = _animeDetailsUnset,
  }) =>
      AnimeEntryDetails(
        features: identical(features, _animeDetailsUnset)
            ? this.features
            : features as String?,
        hdrFormats: hdrFormats ?? this.hdrFormats,
        boxSetId: identical(boxSetId, _animeDetailsUnset)
            ? this.boxSetId
            : boxSetId as String?,
        boxSetName: identical(boxSetName, _animeDetailsUnset)
            ? this.boxSetName
            : boxSetName as String?,
        region: identical(region, _animeDetailsUnset)
            ? this.region
            : region as String?,
        packaging: identical(packaging, _animeDetailsUnset)
            ? this.packaging
            : packaging as String?,
        distributor: identical(distributor, _animeDetailsUnset)
            ? this.distributor
            : distributor as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeEntryDetails &&
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
