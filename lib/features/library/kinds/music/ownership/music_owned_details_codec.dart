import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

class MusicOwnedDetailsCodec implements OwnedDetailsCodec<MusicOwnedDetails> {
  const MusicOwnedDetailsCodec();

  @override
  MusicOwnedDetails fromJson(Map<String, dynamic> json) =>
      MusicOwnedDetails.fromJson(json);

  @override
  Map<String, dynamic> toJson(MusicOwnedDetails details) => details.toJson();

  @override
  Map<String, dynamic> toSyncPayload(MusicOwnedDetails details) =>
      details.toJson();

  @override
  MusicOwnedDetails defaultDetails() => const MusicOwnedDetails();

  @override
  OwnedDetailsDraft defaultDraft() => const MusicOwnedDetailsDraft();

  @override
  OwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return MusicOwnedDetailsDraft(
      storageDevice: personal.storageDevice,
      storageSlot: personal.storageSlot,
    );
  }
}
