import 'package:collectarr_app/features/library/kinds/music/domain/music_track_duration.dart';

/// Editable, kind-entry child values for a manual Music Catalog Item.
///
/// These drafts contain disc and track data for the selected concrete Music
/// Catalog Item. Their sequence in the parent list defines catalog order.
final class MusicAddManualNamedCredit {
  MusicAddManualNamedCredit({
    String? id,
    this.name = '',
    this.sortName = '',
    this.instrument = '',
  }) : id = id ?? _nextId('credit');

  final String id;
  String name;
  String sortName;
  String instrument;

  Map<String, Object?> toCatalogData() => {
        'name': name.trim(),
        if (sortName.trim().isNotEmpty) 'sort_name': sortName.trim(),
        if (instrument.trim().isNotEmpty) 'instrument': instrument.trim(),
      };
}

final class MusicAddManualDisc {
  MusicAddManualDisc({
    String? id,
    this.title = '',
    this.matrixNumberSideA = '',
    this.matrixNumberSideB = '',
    List<MusicAddManualTrack> tracks = const [],
  })  : id = id ?? _nextId('disc'),
        tracks = List.of(tracks);

  final String id;
  String title;
  String matrixNumberSideA;
  String matrixNumberSideB;
  final List<MusicAddManualTrack> tracks;

  Map<String, Object?> toProposalData(int discNumber) => {
        'disc_number': discNumber,
        if (title.trim().isNotEmpty) 'title': title.trim(),
        if (matrixNumberSideA.trim().isNotEmpty)
          'matrix_number_side_a': matrixNumberSideA.trim(),
        if (matrixNumberSideB.trim().isNotEmpty)
          'matrix_number_side_b': matrixNumberSideB.trim(),
        'tracks': [
          for (final (index, track) in tracks
              .where(
                  (track) => !track.isHeader && track.title.trim().isNotEmpty)
              .indexed)
            track.toProposalData(index + 1),
        ],
      };
}

final class MusicAddManualTrack {
  MusicAddManualTrack({
    String? id,
    this.position = '',
    this.isHeader = false,
    this.indentLevel = 0,
    this.parentHeaderId,
    this.title = '',
    this.artist = '',
    this.duration = '',
  }) : id = id ?? _nextId('track');

  final String id;
  String title;
  String artist;
  String duration;
  String position;
  bool isHeader;
  int indentLevel;
  String? parentHeaderId;

  Map<String, Object?> toProposalData(int positionOrder) => {
        'position':
            position.trim().isEmpty ? '$positionOrder' : position.trim(),
        'title': title.trim(),
        if (artist.trim().isNotEmpty) 'artist': artist.trim(),
        if (parseMusicTrackDurationMs(duration) case final durationMs?)
          'duration_ms': durationMs,
      };

  int? get durationMs => parseMusicTrackDurationMs(duration);
}

final class MusicAddManualExternalLink {
  MusicAddManualExternalLink({
    String? id,
    this.title = '',
    this.url = '',
    this.description = '',
  }) : id = id ?? _nextId('link');

  final String id;
  String title;
  String url;
  String description;

  Map<String, Object?> toProposalData() => {
        if (title.trim().isNotEmpty) 'title': title.trim(),
        'url': url.trim(),
        if (description.trim().isNotEmpty) 'description': description.trim(),
      };
}

int _nextManualContentId = 0;

String _nextId(String prefix) => 'music-add-$prefix-${_nextManualContentId++}';
