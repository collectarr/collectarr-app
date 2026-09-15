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
        media: details.media,
        signedBy: details.signedBy,
        lastCleanedDate: details.lastCleanedDate,
      );

  MusicOwnedDetailsDraft defaultDraft() => const MusicOwnedDetailsDraft();
}
