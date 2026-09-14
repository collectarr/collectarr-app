import 'package:flutter/foundation.dart';

@immutable
final class MoviePhysicalCopyDetails {
  const MoviePhysicalCopyDetails({
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

  factory MoviePhysicalCopyDetails.fromJson(Map<String, dynamic> json) {
    return MoviePhysicalCopyDetails(
      features: json['features'] as String?,
      hdrFormats: (json['hdr_formats'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      boxSetId: json['box_set_id'] as String?,
      boxSetName: json['box_set_name'] as String?,
      region: json['region'] as String?,
      packaging: json['packaging'] as String?,
      distributor: json['distributor'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoviePhysicalCopyDetails &&
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
