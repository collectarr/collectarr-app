import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details_draft.dart';

final class TvOwnedDetailsCodec {
  const TvOwnedDetailsCodec();

  TvOwnedDetails fromJson(Map<String, dynamic> json) =>
      TvOwnedDetails.fromJson(json);

  Map<String, dynamic> toJson(TvOwnedDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(TvOwnedDetails details) =>
      details.toJson();

  TvOwnedDetails defaultDetails() => const TvOwnedDetails();

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

  TvOwnedDetailsDraft defaultDraft() => const TvOwnedDetailsDraft();
}
