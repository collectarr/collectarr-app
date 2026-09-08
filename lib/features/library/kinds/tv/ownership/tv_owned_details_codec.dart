import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_draft.dart';

class TvOwnedDetailsCodec
    extends OwnedDetailsCodec<TvOwnedDetails, TvOwnedDetailsDraft> {
  const TvOwnedDetailsCodec();

  @override
  TvOwnedDetails fromJson(Map<String, dynamic> json) =>
      TvOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(TvOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(TvOwnedDetails details) =>
      details.toJson();

  @override
  TvOwnedDetails defaultDetails() => const TvOwnedDetails();

  @override
  TvOwnedDetailsDraft draftFromDetails(TvOwnedDetails details) =>
      TvOwnedDetailsDraft(
        features: details.features,
        hdrFormats: details.hdrFormats,
        boxSetId: details.boxSetId,
        boxSetName: details.boxSetName,
        region: details.region,
        packaging: details.packaging,
        distributor: details.distributor,
      );

  @override
  TvOwnedDetailsDraft defaultDraft() => const TvOwnedDetailsDraft();
}
