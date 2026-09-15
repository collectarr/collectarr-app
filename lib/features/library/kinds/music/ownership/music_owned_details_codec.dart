import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details_draft.dart';

final class MusicOwnedDetailsCodec {
  const MusicOwnedDetailsCodec();

  MusicOwnedDetails fromJson(Map<String, dynamic> json) =>
      MusicOwnedDetails.fromJson(json);

  Map<String, dynamic> toJson(MusicOwnedDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(MusicOwnedDetails details) =>
      details.toJson();

  MusicOwnedDetails defaultDetails() => const MusicOwnedDetails();

  MusicOwnedDetailsDraft draftFromDetails(MusicOwnedDetails details) =>
      MusicOwnedDetailsDraft(
        storageDevice: details.storageDevice,
        storageSlot: details.storageSlot,
        signedBy: details.signedBy,
        lastCleanedDate: details.lastCleanedDate,
        matrixRunouts: details.matrixRunouts,
        discStorage: details.discStorage,
      );

  MusicOwnedDetailsDraft defaultDraft() => const MusicOwnedDetailsDraft();
}
