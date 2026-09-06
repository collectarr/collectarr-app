import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details_draft.dart';

class GenericOwnedDetailsCodec
    implements
        OwnedDetailsCodec<GenericOwnedDetails, GenericOwnedDetailsDraft> {
  const GenericOwnedDetailsCodec();

  @override
  GenericOwnedDetails fromJson(Map<String, dynamic> json) =>
      const GenericOwnedDetails();

  @override
  Map<String, dynamic> toJson(GenericOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(GenericOwnedDetails details) =>
      details.toJson();

  @override
  GenericOwnedDetails defaultDetails() => const GenericOwnedDetails();

  @override
  GenericOwnedDetailsDraft draftFromDetails(GenericOwnedDetails details) =>
      const GenericOwnedDetailsDraft();

  @override
  GenericOwnedDetailsDraft defaultDraft() => const GenericOwnedDetailsDraft();

  @override
  GenericOwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) =>
      const GenericOwnedDetailsDraft();
}
