import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/music/entries/music_entry_details_draft.dart';

final class MusicEntryDetailsCodec {
  const MusicEntryDetailsCodec();

  MusicEntryDetails fromJson(Map<String, dynamic> json) =>
      MusicEntryDetails.fromJson(json);

  Map<String, dynamic> toJson(MusicEntryDetails details) => details.toJson();

  Map<String, dynamic> toSyncPayload(MusicEntryDetails details) =>
      details.toJson();

  MusicEntryDetails defaultDetails() => const MusicEntryDetails();

  MusicEntryDetailsDraft draftFromDetails(MusicEntryDetails details) =>
      MusicEntryDetailsDraft(
        media: details.media,
        signedBy: details.signedBy,
        lastCleanedDate: details.lastCleanedDate,
        lastCleanedDateParts: details.lastCleanedDateParts,
      );

  MusicEntryDetailsDraft defaultDraft() => const MusicEntryDetailsDraft();
}
