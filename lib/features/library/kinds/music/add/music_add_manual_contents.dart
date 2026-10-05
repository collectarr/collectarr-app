import 'package:uuid/uuid.dart';
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
    this.format = '',
    List<String> soundTypes = const [],
    this.vinylColor = '',
    this.vinylWeight = '',
    this.rpm,
    this.spars = '',
    this.matrixNumberSideA = '',
    this.matrixNumberSideB = '',
    List<MusicAddManualTrack> tracks = const [],
  })  : id = id ?? const Uuid().v4(),
        soundTypes = List.of(soundTypes),
        tracks = List.of(tracks);

  final String id;
  String title;
  String format;
  List<String> soundTypes;
  String vinylColor;
  String vinylWeight;
  int? rpm;
  String spars;
  String matrixNumberSideA;
  String matrixNumberSideB;
  final List<MusicAddManualTrack> tracks;

  Map<String, Object?> toProposalData(int discNumber) => {
        'id': id,
        'disc_number': discNumber,
        if (title.trim().isNotEmpty) 'title': title.trim(),
        if (format.trim().isNotEmpty) 'format': format.trim(),
        if (soundTypes.isNotEmpty) 'sound_types': soundTypes,
        if (vinylColor.trim().isNotEmpty) 'vinyl_color': vinylColor.trim(),
        if (vinylWeight.trim().isNotEmpty) 'vinyl_weight': vinylWeight.trim(),
        if (rpm != null) 'rpm': rpm,
        if (spars.trim().isNotEmpty) 'spars': spars.trim(),
        if (matrixNumberSideA.trim().isNotEmpty)
          'matrix_number_side_a': matrixNumberSideA.trim(),
        if (matrixNumberSideB.trim().isNotEmpty)
          'matrix_number_side_b': matrixNumberSideB.trim(),
        'tracks': [
          for (final (index, track)
              in tracks.where((track) => track.title.trim().isNotEmpty).indexed)
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
  }) : id = id ?? const Uuid().v4();

  final String id;
  String title;
  String artist;
  String duration;
  String position;
  bool isHeader;
  int indentLevel;
  String? parentHeaderId;

  Map<String, Object?> toProposalData(int positionOrder) => {
        'id': id,
        'position': isHeader
            ? ''
            : position.trim().isEmpty
                ? '$positionOrder'
                : position.trim(),
        'position_order': positionOrder,
        'title': title.trim(),
        'is_header': isHeader,
        'indent_level': indentLevel,
        if (parentHeaderId != null) 'parent_header_id': parentHeaderId,
        if (!isHeader && artist.trim().isNotEmpty) 'artist': artist.trim(),
        if (!isHeader)
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
