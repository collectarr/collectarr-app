import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';

class TvOwnedDetailsDraft implements JsonEncodable {
  const TvOwnedDetailsDraft({
    this.features,
    this.hdrFormats = const [],
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

  TvOwnedDetails toDetails() => TvOwnedDetails(
        features: features,
        hdrFormats: hdrFormats,
        boxSetId: boxSetId,
        boxSetName: boxSetName,
        region: region,
        packaging: packaging,
        distributor: distributor,
      );

  @override
  Map<String, dynamic> toJson() => toDetails().toJson();
}
