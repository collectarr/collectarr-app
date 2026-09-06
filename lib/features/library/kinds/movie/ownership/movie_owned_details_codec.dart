import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';

class MovieOwnedDetailsCodec
    extends OwnedDetailsCodec<MovieOwnedDetails, MovieOwnedDetailsDraft> {
  const MovieOwnedDetailsCodec();

  @override
  MovieOwnedDetails fromJson(Map<String, dynamic> json) =>
      MovieOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(MovieOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(MovieOwnedDetails details) =>
      details.toJson();

  @override
  MovieOwnedDetails defaultDetails() => const MovieOwnedDetails();

  @override
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

  @override
  MovieOwnedDetailsDraft defaultDraft() => const MovieOwnedDetailsDraft();

  @override
  MovieOwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return MovieOwnedDetailsDraft(
      features: personal.features,
      hdrFormats: personal.hdrFormats ?? const [],
      boxSetName: personal.boxSetName,
      region: personal.region,
      packaging: personal.packaging,
      distributor: personal.distributor,
    );
  }
}
