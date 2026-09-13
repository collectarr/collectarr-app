import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';

final class MovieOwnedDetailsCodec {
  const MovieOwnedDetailsCodec();

  MovieOwnedDetails fromJson(Map<String, dynamic> json) =>
      MovieOwnedDetails.fromJson(json);

  Map<String, dynamic> toJson(MovieOwnedDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(MovieOwnedDetails details) =>
      details.toJson();

  MovieOwnedDetails defaultDetails() => const MovieOwnedDetails();

  MovieOwnedDetailsDraft draftFromDetails(MovieOwnedDetails details) =>
      MovieOwnedDetailsDraft(
        features: details.features,
        hdrFormats: details.hdrFormats,
        boxSetId: details.boxSetId,
        boxSetName: details.boxSetName,
        region: details.region,
        packaging: details.packaging,
        distributor: details.distributor,
      );

  MovieOwnedDetailsDraft defaultDraft() => const MovieOwnedDetailsDraft();
}
