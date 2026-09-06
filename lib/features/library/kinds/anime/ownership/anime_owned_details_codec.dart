import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details_draft.dart';

class AnimeOwnedDetailsCodec
    implements OwnedDetailsCodec<AnimeOwnedDetails, AnimeOwnedDetailsDraft> {
  const AnimeOwnedDetailsCodec();

  @override
  AnimeOwnedDetails fromJson(Map<String, dynamic> json) =>
      AnimeOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(AnimeOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(AnimeOwnedDetails details) =>
      details.toJson();

  @override
  AnimeOwnedDetails defaultDetails() => const AnimeOwnedDetails();

  @override
  AnimeOwnedDetailsDraft draftFromDetails(AnimeOwnedDetails details) =>
      AnimeOwnedDetailsDraft(
        features: details.features,
        hdrFormats: details.hdrFormats,
        boxSetId: details.boxSetId,
        boxSetName: details.boxSetName,
        region: details.region,
        packaging: details.packaging,
        distributor: details.distributor,
      );

  @override
  AnimeOwnedDetailsDraft defaultDraft() => const AnimeOwnedDetailsDraft();

  @override
  AnimeOwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return AnimeOwnedDetailsDraft(
      features: personal.features,
      hdrFormats: personal.hdrFormats ?? const [],
      boxSetName: personal.boxSetName,
      region: personal.region,
      packaging: personal.packaging,
      distributor: personal.distributor,
    );
  }
}
