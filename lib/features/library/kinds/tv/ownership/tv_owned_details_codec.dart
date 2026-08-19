import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';

class TvOwnedDetailsCodec implements OwnedDetailsCodec<TvOwnedDetails> {
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
  OwnedDetailsDraft defaultDraft() => const TvOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return TvOwnedDetailsDraft(
      features: personal.features,
      hdrFormats: personal.hdrFormats ?? const [],
      boxSetName: personal.boxSetName,
      region: personal.region,
      packaging: personal.packaging,
      distributor: personal.distributor,
    );
  }
}
