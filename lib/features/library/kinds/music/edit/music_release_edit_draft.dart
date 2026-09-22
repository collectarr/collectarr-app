import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';

final class MusicReleaseEditDraft {
  MusicReleaseEditDraft.fromRelease(
    MusicRelease release, {
    TrackingSummary? trackingSummary,
  })  : original = release,
        title = release.title,
        sortTitle = release.sortTitle,
        subtitle = release.subtitle,
        releaseType = release.releaseType,
        releaseStatus = release.releaseStatus,
        releaseDate = release.releaseDate,
        publisher = release.publisher,
        countryCode = release.countryCode,
        language = release.language,
        barcode = release.barcode,
        upc = release.upc,
        catalogNumber = release.catalogNumber,
        packaging = release.packaging,
        physicalFormat = release.physicalFormat,
        physicalFormatLabel = release.physicalFormatLabel,
        coverImageUrl = release.coverImageUrl,
        mediums = [
          for (final medium in release.mediums) _copyMedium(medium),
        ],
        externalLinks = List.of(release.externalLinks),
        boxSetMembership = release.boxSetMembership,
        trackingStatus = trackingSummary?.statusStorageValue,
        trackingRating = trackingSummary?.rating,
        trackingNotes = trackingSummary?.notes,
        _trackingSummary = trackingSummary;

  final MusicRelease original;
  String title;
  String? sortTitle;
  String? subtitle;
  String? releaseType;
  String? releaseStatus;
  DateTime? releaseDate;
  String? publisher;
  String? countryCode;
  String? language;
  String? barcode;
  String? upc;
  String? catalogNumber;
  String? packaging;
  String? physicalFormat;
  String? physicalFormatLabel;
  String? coverImageUrl;
  final List<MusicMedium> mediums;
  List<MusicExternalLink> externalLinks;
  MusicBoxSetMembership? boxSetMembership;

  String? trackingStatus;
  int? trackingRating;
  String? trackingNotes;

  final TrackingSummary? _trackingSummary;

  void addMedium() {
    final nextNumber = mediums.fold<int>(
          0,
          (largest, medium) =>
              medium.mediumNumber > largest ? medium.mediumNumber : largest,
        ) +
        1;
    mediums.add(
      MusicMedium(
        id: MusicMediumId(
          '${original.id.value}:medium:${DateTime.now().microsecondsSinceEpoch}',
        ),
        releaseId: original.id,
        mediumNumber: nextNumber,
        mediumType: original.physicalFormat,
        tracks: const [],
      ),
    );
  }

  void updateMediumType(MusicMediumId mediumId, String value) {
    final index = mediums.indexWhere((medium) => medium.id == mediumId);
    if (index < 0) return;
    mediums[index] = _copyMedium(
      mediums[index],
      mediumType: _text(value),
      replaceMediumType: true,
    );
  }

  void updateMediumTitle(MusicMediumId mediumId, String title) {
    final index = mediums.indexWhere((medium) => medium.id == mediumId);
    if (index < 0) return;
    mediums[index] = _copyMedium(
      mediums[index],
      title: _text(title),
      replaceTitle: true,
    );
  }

  void replaceTrack(
    MusicMediumId mediumId,
    int index,
    MusicTrack track,
  ) {
    final mediumIndex = mediums.indexWhere((medium) => medium.id == mediumId);
    if (mediumIndex < 0) return;
    final medium = mediums[mediumIndex];
    if (index < 0 || index >= medium.tracks.length) return;
    final tracks = List<MusicTrack>.of(medium.tracks);
    tracks[index] = track;
    mediums[mediumIndex] = _copyMedium(medium, tracks: tracks);
  }

  void addTrack(MusicMediumId mediumId, {required bool header}) {
    final mediumIndex = mediums.indexWhere((medium) => medium.id == mediumId);
    if (mediumIndex < 0) return;
    final medium = mediums[mediumIndex];
    final nextPosition =
        medium.tracks.where((track) => !track.isHeader).length + 1;
    MusicTrack? parentHeader;
    if (!header) {
      for (final existing in medium.tracks.reversed) {
        if (existing.isHeader) {
          parentHeader = existing;
          break;
        }
      }
    }
    final track = MusicTrack(
      id: MusicTrackId(
        '${medium.id.value}:track:${DateTime.now().microsecondsSinceEpoch}',
      ),
      mediumId: medium.id,
      position: header ? '' : nextPosition.toString(),
      title: header ? 'New section' : 'New track',
      isHeader: header,
      indentLevel: header
          ? 0
          : (parentHeader == null ? 0 : parentHeader.indentLevel + 1),
      parentHeaderId: parentHeader?.id.value,
    );
    mediums[mediumIndex] = _copyMedium(
      medium,
      tracks: _renumberTracks([...medium.tracks, track]),
    );
  }

  void removeTrack(MusicMediumId mediumId, int index) {
    final mediumIndex = mediums.indexWhere((medium) => medium.id == mediumId);
    if (mediumIndex < 0) return;
    final medium = mediums[mediumIndex];
    if (index < 0 || index >= medium.tracks.length) return;
    removeTracks(mediumId, {medium.tracks[index].id.value});
  }

  void reorderTrack(MusicMediumId mediumId, int oldIndex, int newIndex) {
    final mediumIndex = mediums.indexWhere((medium) => medium.id == mediumId);
    if (mediumIndex < 0) return;
    final medium = mediums[mediumIndex];
    if (oldIndex < 0 || oldIndex >= medium.tracks.length) return;
    if (newIndex > oldIndex) newIndex--;
    if (newIndex < 0 || newIndex >= medium.tracks.length) return;
    final tracks = List<MusicTrack>.of(medium.tracks);
    final track = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, track);
    mediums[mediumIndex] = _copyMedium(
      medium,
      tracks: _linkHeaderParents(_renumberTracks(tracks)),
    );
  }

  void setTrackIndent(
    MusicMediumId mediumId,
    int index,
    int indentLevel,
  ) {
    final mediumIndex = mediums.indexWhere((medium) => medium.id == mediumId);
    if (mediumIndex < 0) return;
    final medium = mediums[mediumIndex];
    if (index < 0 || index >= medium.tracks.length) return;
    final track = medium.tracks[index];
    MusicTrack? parentHeader;
    if (indentLevel > 0) {
      for (var previous = index - 1; previous >= 0; previous--) {
        final candidate = medium.tracks[previous];
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
    final tracks = List<MusicTrack>.of(medium.tracks);
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
    mediums[mediumIndex] = _copyMedium(
      medium,
      tracks: _linkHeaderParents(tracks),
    );
  }

  void autocapTracks(MusicMediumId mediumId, Set<String> trackIds) {
    if (trackIds.isEmpty) return;
    final mediumIndex = mediums.indexWhere((medium) => medium.id == mediumId);
    if (mediumIndex < 0) return;
    final medium = mediums[mediumIndex];
    final tracks = [
      for (final track in medium.tracks)
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
    mediums[mediumIndex] = _copyMedium(medium, tracks: tracks);
  }

  void removeTracks(MusicMediumId mediumId, Set<String> trackIds) {
    if (trackIds.isEmpty) return;
    final mediumIndex = mediums.indexWhere((medium) => medium.id == mediumId);
    if (mediumIndex < 0) return;
    final medium = mediums[mediumIndex];
    final remaining = medium.tracks
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
    mediums[mediumIndex] = _copyMedium(
      medium,
      tracks: _linkHeaderParents(_renumberTracks(remaining)),
    );
  }

  void moveTracksToMedium({
    required MusicMediumId sourceId,
    required MusicMediumId destinationId,
    required Set<String> trackIds,
  }) {
    if (trackIds.isEmpty || sourceId == destinationId) return;
    final sourceIndex = mediums.indexWhere((medium) => medium.id == sourceId);
    final destinationIndex =
        mediums.indexWhere((medium) => medium.id == destinationId);
    if (sourceIndex < 0 || destinationIndex < 0) return;

    final source = mediums[sourceIndex];
    final destination = mediums[destinationIndex];
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
          mediumId: destination.id,
          clearParentHeaderId: track.parentHeaderId != null &&
              !movingIds.contains(track.parentHeaderId) &&
              !destinationTrackIds.contains(track.parentHeaderId),
        ),
    ];
    mediums[sourceIndex] = _copyMedium(
      source,
      tracks: _linkHeaderParents(_renumberTracks(sourceTracks)),
    );
    mediums[destinationIndex] = _copyMedium(
      destination,
      tracks: _linkHeaderParents(
        _renumberTracks([...destination.tracks, ...movedTracks]),
      ),
    );
  }

  bool get hasTrackingEdits =>
      _trackingSummary != null ||
      trackingStatus != null ||
      trackingRating != null ||
      trackingNotes != null;

  LibraryTrackingEditSelection? trackingSelection(
    CatalogEntityRef targetRef,
  ) {
    if (!hasTrackingEdits) return null;
    return LibraryTrackingEditSelection(
      targetRef: targetRef,
      rating: trackingRating,
      readStatus: _text(trackingStatus),
      notes: _text(trackingNotes),
    );
  }

  MusicRelease toRelease() => MusicRelease(
        id: original.id,
        releaseGroupId: original.releaseGroupId,
        title: title.trim(),
        sortTitle: _text(sortTitle),
        subtitle: _text(subtitle),
        releaseType: _text(releaseType),
        releaseStatus: _text(releaseStatus),
        releaseDate: releaseDate,
        releaseDateParts: releaseDate == original.releaseDate
            ? original.releaseDateParts
            : null,
        publisher: _text(publisher),
        countryCode: _text(countryCode),
        language: _text(language),
        barcode: _text(barcode),
        upc: _text(upc),
        catalogNumber: _text(catalogNumber),
        packaging: _text(packaging),
        physicalFormat: _text(physicalFormat),
        physicalFormatLabel: _text(physicalFormatLabel),
        coverImageUrl: _text(coverImageUrl),
        coverImageKey: original.coverImageKey,
        externalLinks: List.unmodifiable(externalLinks),
        boxSetMembership: boxSetMembership,
        createdAt: original.createdAt,
        updatedAt: original.updatedAt,
        contributions: original.contributions,
        artistCredits: original.artistCredits,
        labels: original.labels,
        identifiers: original.identifiers,
        mediums: List.unmodifiable(mediums),
        boxSetName: original.boxSetName,
      );
}

MusicTrack musicTrackWithEdits(
  MusicTrack source, {
  required String title,
  required String position,
  required String artist,
  required int? durationMs,
  int? indentLevel,
  MusicMediumId? mediumId,
  bool clearParentHeaderId = false,
  String? parentHeaderId,
  bool replaceParentHeaderId = false,
}) {
  return MusicTrack(
    id: source.id,
    mediumId: mediumId ?? source.mediumId,
    position: position.trim(),
    title: title.trim().isEmpty ? 'Untitled track' : title.trim(),
    artist: _text(artist),
    recordingId: source.recordingId,
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

MusicMedium _copyMedium(
  MusicMedium medium, {
  String? title,
  bool replaceTitle = false,
  String? mediumType,
  bool replaceMediumType = false,
  List<MusicTrack>? tracks,
}) {
  return MusicMedium(
    id: medium.id,
    releaseId: medium.releaseId,
    mediumNumber: medium.mediumNumber,
    mediumType:
        replaceMediumType ? mediumType : mediumType ?? medium.mediumType,
    title: replaceTitle ? title : title ?? medium.title,
    trackCount: tracks != null && tracks.isEmpty ? 0 : medium.trackCount,
    expectedTrackCount: medium.expectedTrackCount,
    missingTrackCount: medium.missingTrackCount,
    missingTrackPositions: medium.missingTrackPositions,
    toc: medium.toc,
    cddbId: medium.cddbId,
    leadoutOffset: medium.leadoutOffset,
    bpDiscId: medium.bpDiscId,
    mediaCondition: medium.mediaCondition,
    soundType: medium.soundType,
    vinylColor: medium.vinylColor,
    vinylWeight: medium.vinylWeight,
    rpm: medium.rpm,
    spars: medium.spars,
    tracks: tracks ?? medium.tracks,
    createdAt: medium.createdAt,
    updatedAt: medium.updatedAt,
  );
}

List<MusicTrack> _renumberTracks(List<MusicTrack> tracks) {
  var position = 1;
  return [
    for (final track in tracks)
      musicTrackWithEdits(
        track,
        title: track.title,
        position: track.isHeader ? track.position : '${position++}',
        artist: track.artist ?? '',
        durationMs: track.durationMs,
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
