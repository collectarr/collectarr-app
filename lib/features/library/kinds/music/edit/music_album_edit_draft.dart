import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_album_form_values.dart';

final class MusicAlbumEditDraft {
  MusicAlbumEditDraft.fromAlbum(
    MusicAlbum album,
  )   : original = album,
        values = MusicAlbumFormValues.fromAlbum(album),
        contributions = List.of(album.contributions),
        discs = [
          for (final disc in album.discs) _copyDisc(disc),
        ],
        externalLinks = List.of(album.externalLinks);

  final MusicAlbum original;
  final MusicAlbumFormValues values;
  List<MusicAlbumContribution> contributions;
  final List<MusicDisc> discs;
  List<MusicExternalLink> externalLinks;
  bool hasIncompleteContributions = false;

  void addDisc() {
    final nextNumber = discs.fold<int>(
          0,
          (largest, disc) =>
              disc.discNumber > largest ? disc.discNumber : largest,
        ) +
        1;
    discs.add(
      MusicDisc(
        id: MusicDiscId(
          '${original.id.value}:disc:${DateTime.now().microsecondsSinceEpoch}',
        ),
        discNumber: nextNumber,
        tracks: const [],
      ),
    );
  }

  void removeDisc(MusicDiscId discId) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs.removeAt(index);
    _renumberDiscs();
  }

  void reorderDisc(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= discs.length) return;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex < 0 || newIndex >= discs.length || newIndex == oldIndex) {
      return;
    }
    final disc = discs.removeAt(oldIndex);
    discs.insert(newIndex, disc);
    _renumberDiscs();
  }

  void _renumberDiscs() {
    for (var index = 0; index < discs.length; index++) {
      discs[index] = _copyDisc(
        discs[index],
        discNumber: index + 1,
      );
    }
  }

  void updateDiscTitle(MusicDiscId discId, String title) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = _copyDisc(
      discs[index],
      title: _text(title),
      replaceTitle: true,
    );
  }

  void updateDiscTechnicalDetails(
    MusicDiscId discId, {
    String? matrixNumberSideA,
    bool replaceMatrixNumberSideA = false,
    String? matrixNumberSideB,
    bool replaceMatrixNumberSideB = false,
  }) {
    final index = discs.indexWhere((disc) => disc.id == discId);
    if (index < 0) return;
    discs[index] = _copyDisc(
      discs[index],
      matrixNumberSideA: matrixNumberSideA,
      replaceMatrixNumberSideA: replaceMatrixNumberSideA,
      matrixNumberSideB: matrixNumberSideB,
      replaceMatrixNumberSideB: replaceMatrixNumberSideB,
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
    discs[discIndex] = _copyDisc(disc, tracks: tracks);
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
      id: MusicTrackId(
        '${disc.id.value}:track:${DateTime.now().microsecondsSinceEpoch}',
      ),
      position: header ? '' : nextPosition.toString(),
      title: header ? 'New section' : 'New track',
      isHeader: header,
      indentLevel: header
          ? 0
          : (parentHeader == null ? 0 : parentHeader.indentLevel + 1),
      parentHeaderId: parentHeader?.id.value,
    );
    discs[discIndex] = _copyDisc(
      disc,
      tracks: _renumberTracks([...disc.tracks, track]),
    );
  }

  void removeTrack(MusicDiscId discId, int index) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    if (index < 0 || index >= disc.tracks.length) return;
    removeTracks(discId, {disc.tracks[index].id.value});
  }

  void reorderTrack(MusicDiscId discId, int oldIndex, int newIndex) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    if (oldIndex < 0 || oldIndex >= disc.tracks.length) return;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex < 0 || newIndex >= disc.tracks.length) return;
    final tracks = List<MusicTrack>.of(disc.tracks);
    final track = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, track);
    discs[discIndex] = _copyDisc(
      disc,
      tracks: _linkHeaderParents(_renumberTracks(tracks)),
    );
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
    discs[discIndex] = _copyDisc(
      disc,
      tracks: _renumberTracks(tracks),
    );
  }

  void setTrackIndent(
    MusicDiscId discId,
    int index,
    int indentLevel,
  ) {
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    if (index < 0 || index >= disc.tracks.length) return;
    final track = disc.tracks[index];
    MusicTrack? parentHeader;
    if (indentLevel > 0) {
      for (var previous = index - 1; previous >= 0; previous--) {
        final candidate = disc.tracks[previous];
        if (candidate.isHeader && candidate.indentLevel < indentLevel) {
          parentHeader = candidate;
          break;
        }
      }
    }
    final requestedIndent = indentLevel < 0
        ? 0
        : indentLevel > 8
            ? 8
            : indentLevel;
    final effectiveIndent =
        requestedIndent > 0 && parentHeader == null ? 0 : requestedIndent;
    final tracks = List<MusicTrack>.of(disc.tracks);
    tracks[index] = musicTrackWithEdits(
      track,
      title: track.title,
      position: track.position,
      artist: track.artist ?? '',
      durationMs: track.durationMs,
      indentLevel: effectiveIndent,
      parentHeaderId: parentHeader?.id.value,
      replaceParentHeaderId: true,
    );
    discs[discIndex] = _copyDisc(
      disc,
      tracks: _linkHeaderParents(tracks),
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
            title: _autocapTrackTitle(track.title),
            position: track.position,
            artist: track.artist ?? '',
            durationMs: track.durationMs,
          )
        else
          track,
    ];
    discs[discIndex] = _copyDisc(disc, tracks: tracks);
  }

  void removeTracks(MusicDiscId discId, Set<String> trackIds) {
    if (trackIds.isEmpty) return;
    final discIndex = discs.indexWhere((disc) => disc.id == discId);
    if (discIndex < 0) return;
    final disc = discs[discIndex];
    final remaining = disc.tracks
        .where((track) => !trackIds.contains(track.id.value))
        .map(
          (track) => track.parentHeaderId != null &&
                  trackIds.contains(track.parentHeaderId)
              ? musicTrackWithEdits(
                  track,
                  title: track.title,
                  position: track.position,
                  artist: track.artist ?? '',
                  durationMs: track.durationMs,
                  clearParentHeaderId: true,
                )
              : track,
        )
        .toList(growable: false);
    discs[discIndex] = _copyDisc(
      disc,
      tracks: _linkHeaderParents(_renumberTracks(remaining)),
    );
  }

  void moveTracksToDisc({
    required MusicDiscId sourceId,
    required MusicDiscId destinationId,
    required Set<String> trackIds,
  }) {
    if (trackIds.isEmpty || sourceId == destinationId) return;
    final sourceIndex = discs.indexWhere((disc) => disc.id == sourceId);
    final destinationIndex =
        discs.indexWhere((disc) => disc.id == destinationId);
    if (sourceIndex < 0 || destinationIndex < 0) return;

    final source = discs[sourceIndex];
    final destination = discs[destinationIndex];
    final moving = source.tracks
        .where((track) => trackIds.contains(track.id.value))
        .toList(growable: false);
    if (moving.isEmpty) return;
    final movingIds = moving.map((track) => track.id.value).toSet();
    final destinationTrackIds =
        destination.tracks.map((track) => track.id.value).toSet();
    final sourceTracks = source.tracks
        .where((track) => !movingIds.contains(track.id.value))
        .map(
          (track) => track.parentHeaderId != null &&
                  movingIds.contains(track.parentHeaderId)
              ? musicTrackWithEdits(
                  track,
                  title: track.title,
                  position: track.position,
                  artist: track.artist ?? '',
                  durationMs: track.durationMs,
                  clearParentHeaderId: true,
                )
              : track,
        )
        .toList(growable: false);
    final movedTracks = [
      for (final track in moving)
        musicTrackWithEdits(
          track,
          title: track.title,
          position: track.position,
          artist: track.artist ?? '',
          durationMs: track.durationMs,
          clearParentHeaderId: track.parentHeaderId != null &&
              !movingIds.contains(track.parentHeaderId) &&
              !destinationTrackIds.contains(track.parentHeaderId),
        ),
    ];
    discs[sourceIndex] = _copyDisc(
      source,
      tracks: _linkHeaderParents(_renumberTracks(sourceTracks)),
    );
    discs[destinationIndex] = _copyDisc(
      destination,
      tracks: _linkHeaderParents(
        _renumberTracks([...destination.tracks, ...movedTracks]),
      ),
    );
  }

  MusicAlbum toAlbum() => MusicAlbumFormAdapter.update(
        original,
        values,
        discs: discs,
        externalLinks: externalLinks
            .where((link) => link.url.trim().isNotEmpty)
            .toList(growable: false),
        contributions: contributions,
      );
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

MusicDisc _copyDisc(
  MusicDisc disc, {
  int? discNumber,
  String? title,
  bool replaceTitle = false,
  String? matrixNumberSideA,
  bool replaceMatrixNumberSideA = false,
  String? matrixNumberSideB,
  bool replaceMatrixNumberSideB = false,
  List<MusicTrack>? tracks,
}) {
  return MusicDisc(
    id: disc.id,
    discNumber: discNumber ?? disc.discNumber,
    title: replaceTitle ? title : title ?? disc.title,
    matrixNumberSideA: replaceMatrixNumberSideA
        ? matrixNumberSideA
        : matrixNumberSideA ?? disc.matrixNumberSideA,
    matrixNumberSideB: replaceMatrixNumberSideB
        ? matrixNumberSideB
        : matrixNumberSideB ?? disc.matrixNumberSideB,
    tracks: tracks ?? disc.tracks,
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

String _autocapTrackTitle(String value) {
  const minorWords = {
    'a',
    'an',
    'and',
    'as',
    'at',
    'but',
    'by',
    'for',
    'from',
    'in',
    'into',
    'nor',
    'of',
    'on',
    'or',
    'over',
    'per',
    'the',
    'to',
    'up',
    'via',
    'with',
  };
  final wordPattern = RegExp(
    r"[A-Za-zÀ-ÖØ-öø-ÿ0-9]+(?:['’][A-Za-zÀ-ÖØ-öø-ÿ0-9]+)*",
  );
  final words = wordPattern.allMatches(value).toList(growable: false);
  var index = 0;
  return value.replaceAllMapped(wordPattern, (match) {
    final source = match.group(0)!;
    final wordIndex = index++;
    final normalized = source.toLowerCase();
    final letters = source.replaceAll(RegExp(r'[^A-Za-z]'), '');
    final shortAcronym = letters.length > 1 &&
        letters.length <= 4 &&
        letters == letters.toUpperCase();
    if (shortAcronym) return source;
    if (minorWords.contains(normalized) &&
        wordIndex > 0 &&
        wordIndex < words.length - 1) {
      return normalized;
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  });
}
