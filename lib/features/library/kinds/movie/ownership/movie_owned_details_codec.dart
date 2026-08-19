import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details.dart';

class MovieOwnedDetailsCodec implements OwnedDetailsCodec<MovieOwnedDetails> {
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
  OwnedDetailsDraft defaultDraft() => const MovieOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
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
