import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';

final class MusicMediaEditDraft {
  MusicMediaEditDraft.fromMedia(MusicMedia media)
      : original = media,
        mediaNumber = media.mediaNumber,
        mediaCondition = media.mediaCondition,
        mediaType = media.mediaType,
        packaging = media.packaging,
        rpm = media.rpm,
        soundType = media.soundType,
        spars = media.spars,
        title = media.title,
        trackCount = media.trackCount,
        vinylColor = media.vinylColor,
        vinylWeight = media.vinylWeight;

  final MusicMedia original;
  int mediaNumber;
  String? mediaCondition;
  String? mediaType;
  String? packaging;
  int? rpm;
  String? soundType;
  String? spars;
  String? title;
  int? trackCount;
  String? vinylColor;
  String? vinylWeight;

  MusicMedia toMedia() => MusicMedia(
        id: original.id,
        releaseId: original.releaseId,
        mediaNumber: mediaNumber,
        mediaCondition: _text(mediaCondition),
        mediaType: _text(mediaType),
        packaging: _text(packaging),
        rpm: rpm,
        soundType: _text(soundType),
        spars: _text(spars),
        title: _text(title),
        trackCount: trackCount,
        tracks: original.tracks,
        vinylColor: _text(vinylColor),
        vinylWeight: _text(vinylWeight),
        rawPayload: original.rawPayload,
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
