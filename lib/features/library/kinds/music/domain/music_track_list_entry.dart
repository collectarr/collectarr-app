import 'package:flutter/foundation.dart';

import 'music_track.dart';

/// A typed Music track together with the disc it is displayed under.
///
/// The disc number is presentation context, not a second track identity.
/// Keeping this adapter inside Music prevents the inspector from rebuilding
/// tracks into the generic catalog track DTO and losing Music fields.
@immutable
final class MusicTrackListEntry {
  const MusicTrackListEntry({
    required this.discNumber,
    required this.track,
    this.albumId,
    this.albumTitle,
    this.catalogNumber,
  });

  final int discNumber;
  final MusicTrack track;
  final String? albumId;
  final String? albumTitle;
  final String? catalogNumber;

  String get position => track.position;
  String get title => track.title;
  String? get artist => track.artist;
  int? get durationSeconds => track.durationSeconds;
  bool get isHeader => track.isHeader;
  int get indentLevel => track.indentLevel;
  String? get parentHeaderId => track.parentHeaderId;
}
