/// Editable, kind-entry child values for a manual Music Catalog Item.
///
/// These drafts contain disc and track data for the selected concrete Music
/// Catalog Item. Their sequence in the parent list defines catalog order.
final class MusicAddManualNamedCredit {
  MusicAddManualNamedCredit({
    this.name = '',
    this.sortName = '',
    this.instrument = '',
  }) : id = _nextId('credit');

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
    this.title = '',
    this.matrixNumberSideA = '',
    this.matrixNumberSideB = '',
    List<MusicAddManualTrack> tracks = const [],
  })  : id = _nextId('disc'),
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
          for (final (index, track)
              in tracks.where((track) => track.title.trim().isNotEmpty).indexed)
            track.toProposalData(index + 1),
        ],
      };
}

final class MusicAddManualTrack {
  MusicAddManualTrack({
    this.title = '',
    this.artist = '',
    this.duration = '',
  }) : id = _nextId('track');

  final String id;
  String title;
  String artist;
  String duration;

  Map<String, Object?> toProposalData(int positionOrder) => {
        'position': '$positionOrder',
        'title': title.trim(),
        if (artist.trim().isNotEmpty) 'artist': artist.trim(),
        if (_durationMilliseconds(duration) case final durationMs?)
          'duration_ms': durationMs,
      };

  int? get durationMs => _durationMilliseconds(duration);
}

final class MusicAddManualExternalLink {
  MusicAddManualExternalLink({
    this.title = '',
    this.url = '',
    this.description = '',
  }) : id = _nextId('link');

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

int? _durationMilliseconds(String value) {
  final parts = value.trim().split(':');
  if (parts.isEmpty || parts.any((part) => int.tryParse(part) == null)) {
    return null;
  }
  final parsed = parts.map(int.parse).toList(growable: false);
  if (parsed.any((part) => part < 0)) return null;
  if (parsed.length == 2 && parsed[1] >= 60) return null;
  if (parsed.length == 3 && (parsed[1] >= 60 || parsed[2] >= 60)) return null;
  if (parsed.length < 2 || parsed.length > 3) return null;
  final seconds = parsed.length == 2
      ? parsed[0] * 60 + parsed[1]
      : parsed[0] * 3600 + parsed[1] * 60 + parsed[2];
  return seconds * 1000;
}
