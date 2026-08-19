import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';

class GenericOwnedDetailsCodec
    implements OwnedDetailsCodec<GenericOwnedDetails> {
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
  OwnedDetailsDraft defaultDraft() => const GenericOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) =>
      const GenericOwnedDetailsDraft();
}
