import 'package:uuid/uuid.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc_format_family.dart';
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

  Map<String, Object?> toCatalogData({required int sequence}) => {
        'id': id,
        'person_id': id,
        'name': name.trim(),
        'sequence': sequence,
        if (sortName.trim().isNotEmpty) 'sort_name': sortName.trim(),
        if (instrument.trim().isNotEmpty) 'instrument': instrument.trim(),
      };
}

final class MusicAddManualDisc {
  MusicAddManualDisc({
    String? id,
    this.title = '',
    this.formatFamily,
    this.format = '',
    List<String> soundTypes = const [],
    this.color = '',
    this.vinylWeightGrams,
    this.rpm,
    this.matrixNumber = '',
    this.matrixNumberSideA = '',
    this.matrixNumberSideB = '',
    List<MusicAddManualTrack> tracks = const [],
  })  : id = id ?? const Uuid().v4(),
        soundTypes = List.of(soundTypes),
        tracks = List.of(tracks);

  final String id;
  String title;
  MusicDiscFormatFamily? formatFamily;
  String format;
  List<String> soundTypes;
  String color;
  int? vinylWeightGrams;
  String? rpm;
  String matrixNumber;
  String matrixNumberSideA;
  String matrixNumberSideB;
  final List<MusicAddManualTrack> tracks;

  Map<String, Object?> toProposalData(int discNumber) => {
        'id': id,
        'disc_number': discNumber,
        if (title.trim().isNotEmpty) 'title': title.trim(),
        if (formatFamily != null) 'format_family': formatFamily!.value,
        if (format.trim().isNotEmpty) 'format': format.trim(),
        if (soundTypes.isNotEmpty) 'sound_types': soundTypes,
        if (color.trim().isNotEmpty) 'color': color.trim(),
        if (vinylWeightGrams != null) 'vinyl_weight_grams': vinylWeightGrams,
        if (rpm != null && rpm!.trim().isNotEmpty) 'rpm': rpm!.trim(),
        if (matrixNumber.trim().isNotEmpty)
          'matrix_number': matrixNumber.trim(),
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
