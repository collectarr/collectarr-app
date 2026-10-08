import 'package:uuid/uuid.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_title_formatting.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track_duration.dart';
import 'package:collectarr_app/features/library/kinds/music/edit/music_disc_edit_utils.dart';

/// Owns track rows, their hierarchy, ordering, and duration edit state.
final class MusicTrackListEditor {
  MusicTrackListEditor(this.discs);

  final List<MusicDisc> discs;
  final Map<String, String> _rawTrackDurationInputs = {};

  void clearDurationInputsFor(Iterable<MusicTrack> tracks) {
    for (final track in tracks) {
      _rawTrackDurationInputs.remove(track.id.value);
    }
  }

  bool get hasInvalidTrackDurationInput => _rawTrackDurationInputs.values.any(
        (value) =>
            value.trim().isNotEmpty && parseMusicTrackDurationMs(value) == null,
      );

  String trackDurationText(MusicTrack track) =>
      _rawTrackDurationInputs[track.id.value] ??
      formatMusicTrackDuration(track.durationMs) ??
      '';

  void setTrackDurationText(
    MusicDiscId discId,
    int index,
    String value,
  ) {
    final disc = discs.where((candidate) => candidate.id == discId).firstOrNull;
    if (disc == null || index < 0 || index >= disc.tracks.length) return;
    final track = disc.tracks[index];
    final normalized = value.trim();
    final durationMs = parseMusicTrackDurationMs(value);
    if (normalized.isNotEmpty && durationMs == null) {
      _rawTrackDurationInputs[track.id.value] = value;
      return;
    }
    _rawTrackDurationInputs.remove(track.id.value);
    replaceTrack(
      discId,
      index,
      musicTrackWithEdits(
        track,
        title: track.title,
        position: track.position,
        artist: track.artist ?? '',
        durationMs: durationMs,
      ),
    );
  }

  void replaceTrack(
    MusicDiscId discId,
    int index,
    MusicTrack track,
  ) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    if (index < 0 || index >= disc.tracks.length) return;
    final tracks = List<MusicTrack>.of(disc.tracks);
    tracks[index] = track;
    discs[discIndex] = copyMusicDisc(disc, tracks: tracks);
  }

  void addTrack(MusicDiscId discId, {required bool header}) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    final nextPosition =
        disc.tracks.where((track) => !track.isHeader).length + 1;
    MusicTrack? parentHeader;
    if (!header) {
      for (final existing in disc.tracks.reversed) {
        if (existing.isHeader) {
          parentHeader = existing;
          break;
        }
      }
    }
    final track = MusicTrack(
      id: MusicTrackId(const Uuid().v4()),
      position: header ? '' : nextPosition.toString(),
      title: header ? 'New section' : 'New track',
      isHeader: header,
      indentLevel: header
          ? 0
          : (parentHeader == null ? 0 : parentHeader.indentLevel + 1),
      parentHeaderId: parentHeader?.id.value,
    );
    discs[discIndex] = copyMusicDisc(
      disc,
      tracks: _renumberTracks([...disc.tracks, track]),
    );
  }

  void insertTrack(
    MusicDiscId discId,
    int index, {
    required bool header,
    int indentLevel = 0,
    String? parentHeaderId,
  }) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    final safeIndex = index.clamp(0, disc.tracks.length);
    final track = MusicTrack(
      id: MusicTrackId(const Uuid().v4()),
      position: '',
      title: header ? 'New section' : 'New track',
      isHeader: header,
      indentLevel: indentLevel,
      parentHeaderId: parentHeaderId,
    );
    final next = List<MusicTrack>.of(disc.tracks)..insert(safeIndex, track);
    discs[discIndex] = copyMusicDisc(
      disc,
      tracks: _linkHeaderParents(_renumberTracks(next)),
    );
  }

  void removeTracks(MusicDiscId discId, Set<String> trackIds) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    for (final id in trackIds) {
      _rawTrackDurationInputs.remove(id);
    }
    final remaining = disc.tracks
        .where((track) => !trackIds.contains(track.id.value))
        .toList();
    discs[discIndex] = copyMusicDisc(
      disc,
      tracks: _linkHeaderParents(_renumberTracks(remaining)),
    );
  }

  void reorderTrack(MusicDiscId discId, int oldIndex, int newIndex) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    if (oldIndex < 0 || oldIndex >= disc.tracks.length) return;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex < 0 ||
        newIndex >= disc.tracks.length ||
        newIndex == oldIndex) {
      return;
    }
    final next = List<MusicTrack>.of(disc.tracks);
    final moved = next.removeAt(oldIndex);
    next.insert(newIndex, moved);
    discs[discIndex] = copyMusicDisc(
      disc,
      tracks: _linkHeaderParents(_renumberTracks(next)),
    );
  }

  void outdentTrack(MusicDiscId discId, int index) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    if (index < 0 || index >= disc.tracks.length) return;
    final track = disc.tracks[index];
    final nextIndent = (track.indentLevel - 1).clamp(0, 8);
    final updated = musicTrackWithEdits(
      track,
      title: track.title,
      position: track.position,
      artist: track.artist ?? '',
      durationMs: track.durationMs,
      indentLevel: nextIndent,
    );
    final next = List<MusicTrack>.of(disc.tracks)..[index] = updated;
    discs[discIndex] = copyMusicDisc(
      disc,
      tracks: _linkHeaderParents(next),
    );
  }

  void indentTrack(MusicDiscId discId, int index) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    if (index < 0 || index >= disc.tracks.length) return;
    final track = disc.tracks[index];
    final nextIndent = (track.indentLevel + 1).clamp(0, 8);
    final updated = musicTrackWithEdits(
      track,
      title: track.title,
      position: track.position,
      artist: track.artist ?? '',
      durationMs: track.durationMs,
      indentLevel: nextIndent,
    );
    final next = List<MusicTrack>.of(disc.tracks)..[index] = updated;
    discs[discIndex] = copyMusicDisc(
      disc,
      tracks: _linkHeaderParents(next),
    );
  }

  void moveTracks(
    MusicDiscId discId,
    List<String> trackIds, {
    required int delta,
  }) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0 || trackIds.isEmpty || delta == 0) return;
    final disc = discs[discIndex];
    final tracks = List<MusicTrack>.of(disc.tracks);
    final idSet = trackIds.toSet();

    if (delta < 0) {
      for (var i = 0; i < tracks.length; i++) {
        if (idSet.contains(tracks[i].id.value)) {
          final target = (i + delta).clamp(0, tracks.length - 1);
          if (target != i) {
            final track = tracks.removeAt(i);
            tracks.insert(target, track);
          }
        }
      }
    } else {
      for (var i = tracks.length - 1; i >= 0; i--) {
        if (idSet.contains(tracks[i].id.value)) {
          final target = (i + delta).clamp(0, tracks.length - 1);
          if (target != i) {
            final track = tracks.removeAt(i);
            tracks.insert(target, track);
          }
        }
      }
    }

    discs[discIndex] = copyMusicDisc(
      disc,
      tracks: _linkHeaderParents(_renumberTracks(tracks)),
    );
  }

  void autocapAllTrackTitles() {
    for (var d = 0; d < discs.length; d++) {
      final disc = discs[d];
      final nextTracks = [
        for (final track in disc.tracks)
          musicTrackWithEdits(
            track,
            title: autocapMusicTitle(track.title),
            position: track.position,
            artist: track.artist ?? '',
            durationMs: track.durationMs,
          ),
      ];
      discs[d] = copyMusicDisc(disc, tracks: nextTracks);
    }
  }

  void copyTracks(MusicDiscId sourceDiscId, MusicDiscId destinationDiscId) {
    final source = discs.where((disc) => disc.id == sourceDiscId).firstOrNull;
    final destinationIndex =
        discs.indexWhere((disc) => disc.id == destinationDiscId);
    if (source == null || destinationIndex < 0) return;
    final destination = discs[destinationIndex];
    final cloned = [
      for (final track in source.tracks)
        MusicTrack(
          id: MusicTrackId(const Uuid().v4()),
          position: '',
          title: track.title,
          artist: track.artist,
          durationMs: track.durationMs,
          isHeader: track.isHeader,
          indentLevel: track.indentLevel,
          parentHeaderId: track.parentHeaderId,
        ),
    ];
    discs[destinationIndex] = copyMusicDisc(
      destination,
      tracks: _linkHeaderParents(
        _renumberTracks([...destination.tracks, ...cloned]),
      ),
    );
  }

  void autocapTracks(MusicDiscId discId, Set<String> trackIds) {
    if (trackIds.isEmpty) return;
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    final tracks = [
      for (final track in disc.tracks)
        if (trackIds.contains(track.id.value) && !track.isHeader)
          musicTrackWithEdits(
            track,
            title: autocapMusicTitle(track.title),
            position: track.position,
            artist: track.artist ?? '',
            durationMs: track.durationMs,
          )
        else
          track,
    ];
    discs[discIndex] = copyMusicDisc(disc, tracks: tracks);
  }

  void assignTrackToHeader(
    MusicDiscId discId, {
    required String trackId,
    required String headerId,
  }) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    final sourceIndex =
        disc.tracks.indexWhere((track) => track.id.value == trackId);
    if (sourceIndex < 0 || disc.tracks[sourceIndex].isHeader) return;
    final headerIndex =
        disc.tracks.indexWhere((track) => track.id.value == headerId);
    if (headerIndex < 0 || !disc.tracks[headerIndex].isHeader) return;

    final tracks = List<MusicTrack>.of(disc.tracks);
    final moved = tracks.removeAt(sourceIndex);
    final targetIndex =
        tracks.indexWhere((track) => track.id.value == headerId);
    final header = tracks[targetIndex];
    var insertAt = targetIndex + 1;
    while (insertAt < tracks.length) {
      final candidate = tracks[insertAt];
      if (candidate.isHeader && candidate.indentLevel <= header.indentLevel) {
        break;
      }
      if (candidate.parentHeaderId == headerId ||
          (!candidate.isHeader && candidate.indentLevel > header.indentLevel)) {
        insertAt++;
        continue;
      }
      break;
    }
    tracks.insert(
      insertAt,
      musicTrackWithEdits(
        moved,
        title: moved.title,
        position: moved.position,
        artist: moved.artist ?? '',
        durationMs: moved.durationMs,
        indentLevel: header.indentLevel + 1,
        parentHeaderId: headerId,
        replaceParentHeaderId: true,
      ),
    );
    discs[discIndex] = copyMusicDisc(
      disc,
      tracks: _renumberTracks(tracks),
    );
  }

  void moveTracksToDisc({
    required MusicDiscId sourceId,
    required MusicDiscId destinationId,
    required Set<String> trackIds,
  }) {
    if (sourceId == destinationId || trackIds.isEmpty) return;
    final sourceIndex = discs.indexWhere((disc) => disc.id == sourceId);
    final destinationIndex =
        discs.indexWhere((disc) => disc.id == destinationId);
    if (sourceIndex < 0 || destinationIndex < 0) return;
    final source = discs[sourceIndex];
    final destination = discs[destinationIndex];
    final idSet = trackIds.toSet();

    final movedTracks = [
      for (final track in source.tracks)
        if (idSet.contains(track.id.value)) track,
    ];
    if (movedTracks.isEmpty) return;

    final sourceTracks = [
      for (final track in source.tracks)
        if (!idSet.contains(track.id.value)) track,
    ];

    final destinationTrackIds =
        destination.tracks.map((t) => t.id.value).toSet();
    final sanitizedMovedTracks = [
      for (final track in movedTracks)
        musicTrackWithEdits(
          track,
          title: track.title,
          position: track.position,
          artist: track.artist ?? '',
          durationMs: track.durationMs,
          clearParentHeaderId:
              !destinationTrackIds.contains(track.parentHeaderId),
        ),
    ];
    discs[sourceIndex] = copyMusicDisc(
      source,
      tracks: _linkHeaderParents(_renumberTracks(sourceTracks)),
    );
    discs[destinationIndex] = copyMusicDisc(
      destination,
      tracks: _linkHeaderParents(
        _renumberTracks([...destination.tracks, ...sanitizedMovedTracks]),
      ),
    );
  }
}

MusicTrack musicTrackWithEdits(
  MusicTrack source, {
  required String title,
  required String position,
  required String artist,
  required int? durationMs,
  int? positionOrder,
  int? indentLevel,
  bool clearParentHeaderId = false,
  String? parentHeaderId,
  bool replaceParentHeaderId = false,
}) {
  return MusicTrack(
    id: source.id,
    position: position.trim(),
    positionOrder: positionOrder ?? source.positionOrder,
    title: title.trim().isEmpty ? 'Untitled track' : title.trim(),
    artist: _text(artist),
    composition: source.composition,
    durationMs: durationMs,
    offsetMs: source.offsetMs,
    bitrateKbps: source.bitrateKbps,
    fileSizeBytes: source.fileSizeBytes,
    trackHash: source.trackHash,
    instrument: source.instrument,
    isHeader: source.isHeader,
    indentLevel: indentLevel ?? source.indentLevel,
    parentHeaderId: replaceParentHeaderId
        ? parentHeaderId
        : clearParentHeaderId
            ? null
            : source.parentHeaderId,
    createdAt: source.createdAt,
    updatedAt: source.updatedAt,
  );
}

List<MusicTrack> _renumberTracks(List<MusicTrack> tracks) {
  var position = 1;
  return [
    for (var index = 0; index < tracks.length; index++)
      musicTrackWithEdits(
        tracks[index],
        title: tracks[index].title,
        position:
            tracks[index].isHeader ? tracks[index].position : '${position++}',
        artist: tracks[index].artist ?? '',
        durationMs: tracks[index].durationMs,
        positionOrder: index + 1,
      ),
  ];
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

List<MusicTrack> _linkHeaderParents(List<MusicTrack> tracks) {
  final headersByIndent = <int, MusicTrack>{};
  final result = <MusicTrack>[];

  MusicTrack? nearestHeader(int indentLevel) {
    MusicTrack? nearest;
    var nearestIndent = -1;
    for (final entry in headersByIndent.entries) {
      if (entry.key < indentLevel && entry.key > nearestIndent) {
        nearest = entry.value;
        nearestIndent = entry.key;
      }
    }
    return nearest;
  }

  for (final track in tracks) {
    final requestedIndent = track.indentLevel < 0
        ? 0
        : track.indentLevel > 8
            ? 8
            : track.indentLevel;
    var indentLevel = requestedIndent;
    MusicTrack? parentHeader;
    if (track.isHeader || indentLevel > 0) {
      parentHeader = nearestHeader(indentLevel);
      if (indentLevel > 0 && parentHeader == null) indentLevel = 0;
    } else if (track.parentHeaderId != null) {
      for (final candidate in headersByIndent.values) {
        if (candidate.id.value == track.parentHeaderId) {
          parentHeader = candidate;
          break;
        }
      }
    }

    final linkedTrack = musicTrackWithEdits(
      track,
      title: track.title,
      position: track.position,
      artist: track.artist ?? '',
      durationMs: track.durationMs,
      indentLevel: indentLevel,
      parentHeaderId: parentHeader?.id.value,
      replaceParentHeaderId: true,
    );
    result.add(linkedTrack);
    if (linkedTrack.isHeader) {
      headersByIndent.removeWhere((level, _) => level >= indentLevel);
      headersByIndent[indentLevel] = linkedTrack;
    }
  }
  return result;
}
