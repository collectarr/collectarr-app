import 'package:flutter/foundation.dart';

import 'music_track.dart';

/// A typed Music track together with the medium it is displayed under.
///
/// The medium number is presentation context, not a second track identity.
/// Keeping this adapter inside Music prevents the inspector from rebuilding
/// tracks into the generic catalog track DTO and losing Music fields.
@immutable
final class MusicTrackListEntry {
  const MusicTrackListEntry({
    required this.mediumNumber,
    required this.track,
  });

  final int mediumNumber;
  final MusicTrack track;

  int get discNumber => mediumNumber;
  String get position => track.position;
  String get title => track.title;
  String? get artist => track.artist;
  int? get durationSeconds => track.durationSeconds;
}
