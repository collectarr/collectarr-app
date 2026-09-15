import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';

final class MusicOwnedEditDraft {
  MusicOwnedEditDraft.fromDetails(MusicOwnedDetails details)
      : original = details,
        media = List<MusicOwnedMediumDetails>.from(details.media),
        signedBy = details.signedBy,
        lastCleanedDate = details.lastCleanedDate;

  final MusicOwnedDetails original;
  List<MusicOwnedMediumDetails> media;
  String? signedBy;
  DateTime? lastCleanedDate;

  MusicOwnedDetails toDetails() => MusicOwnedDetails(
        media: List.unmodifiable(media),
        signedBy: _text(signedBy),
        lastCleanedDate: lastCleanedDate,
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
