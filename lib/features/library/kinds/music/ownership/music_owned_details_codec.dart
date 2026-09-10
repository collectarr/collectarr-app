import 'package:collectarr_app/features/library/config/owned_details_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';

class MusicOwnedDetailsCodec
    extends OwnedDetailsPersistenceCodec<MusicOwnedDetails> {
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

  MusicOwnedDetailsDraft draftFromDetails(MusicOwnedDetails details) =>
      MusicOwnedDetailsDraft(
        storageDevice: details.storageDevice,
        storageSlot: details.storageSlot,
        signedBy: details.signedBy,
        lastCleanedDate: details.lastCleanedDate,
        matrixRunouts: details.matrixRunouts,
      );

  MusicOwnedDetailsDraft defaultDraft() => const MusicOwnedDetailsDraft();
}
