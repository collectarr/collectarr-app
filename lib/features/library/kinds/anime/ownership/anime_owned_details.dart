import 'package:flutter/foundation.dart';
import 'package:collectarr_app/core/models/owned_item_details.dart';
import 'package:collectarr_app/features/library/ownership/primitives/video_physical_copy_details.dart';

const Object _animeDetailsUnset = Object();

@immutable
class AnimeOwnedDetails extends OwnedItemDetails {
  const AnimeOwnedDetails({
    this.physical = const VideoPhysicalCopyDetails(),
    String? features,
    List<String>? hdrFormats,
    String? boxSetId,
    String? boxSetName,
    String? region,
    String? packaging,
    String? distributor,
  })  : _features = features,
        _hdrFormats = hdrFormats,
        _boxSetId = boxSetId,
        _boxSetName = boxSetName,
        _region = region,
        _packaging = packaging,
        _distributor = distributor;

  final VideoPhysicalCopyDetails physical;

  final String? _features;
  final List<String>? _hdrFormats;
  final String? _boxSetId;
  final String? _boxSetName;
  final String? _region;
  final String? _packaging;
  final String? _distributor;

  String? get features => _features ?? physical.features;
  List<String> get hdrFormats => _hdrFormats ?? physical.hdrFormats;
  String? get boxSetId => _boxSetId ?? physical.boxSetId;
  String? get boxSetName => _boxSetName ?? physical.boxSetName;
  String? get region => _region ?? physical.region;
  String? get packaging => _packaging ?? physical.packaging;
  String? get distributor => _distributor ?? physical.distributor;

  @override
  Map<String, dynamic> toJson() => {
        if (features != null) 'features': features,
        if (hdrFormats.isNotEmpty) 'hdr_formats': hdrFormats,
        if (boxSetId != null) 'box_set_id': boxSetId,
        if (boxSetName != null) 'box_set_name': boxSetName,
        if (region != null) 'region': region,
        if (packaging != null) 'packaging': packaging,
        if (distributor != null) 'distributor': distributor,
      };

  factory AnimeOwnedDetails.fromJson(Map<String, dynamic> json) {
    return AnimeOwnedDetails(
      physical: VideoPhysicalCopyDetails.fromJson(json),
    );
  }

  AnimeOwnedDetails copyWith({
    Object? features = _animeDetailsUnset,
    List<String>? hdrFormats,
    Object? boxSetId = _animeDetailsUnset,
    Object? boxSetName = _animeDetailsUnset,
    Object? region = _animeDetailsUnset,
    Object? packaging = _animeDetailsUnset,
    Object? distributor = _animeDetailsUnset,
    VideoPhysicalCopyDetails? physical,
  }) {
    return AnimeOwnedDetails(
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
      physical: physical ?? this.physical,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeOwnedDetails &&
          runtimeType == other.runtimeType &&
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
