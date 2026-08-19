import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';

class AnimeOwnedDetailsCodec implements OwnedDetailsCodec<AnimeOwnedDetails> {
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
  OwnedDetailsDraft defaultDraft() => const AnimeOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
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
