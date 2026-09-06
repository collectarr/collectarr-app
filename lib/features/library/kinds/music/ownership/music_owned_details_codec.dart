import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';

class MusicOwnedDetailsCodec
    extends OwnedDetailsCodec<MusicOwnedDetails, MusicOwnedDetailsDraft> {
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
  MusicOwnedDetailsDraft draftFromDetails(MusicOwnedDetails details) =>
      MusicOwnedDetailsDraft(
        storageDevice: details.storageDevice,
        storageSlot: details.storageSlot,
        signedBy: details.signedBy,
        lastCleanedDate: details.lastCleanedDate,
        matrixRunouts: details.matrixRunouts,
      );

  @override
  MusicOwnedDetailsDraft defaultDraft() => const MusicOwnedDetailsDraft();

  @override
  MusicOwnedDetailsDraft buildDraft(LibraryPersonalEditSelection personal) {
    return MusicOwnedDetailsDraft(
      storageDevice: personal.storageDevice,
      storageSlot: personal.storageSlot,
    );
  }
}
