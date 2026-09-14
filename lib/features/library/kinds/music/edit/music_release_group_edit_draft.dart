import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';

/// Draft for the conceptual MusicBrainz release group (the library item).
final class MusicReleaseGroupEditDraft {
  MusicReleaseGroupEditDraft.fromReleaseGroup(MusicReleaseGroup group)
      : original = group,
        title = group.title,
        sortTitle = group.sortTitle,
        artist = group.artist,
        originalTitle = group.originalTitle,
        synopsis = group.synopsis,
        originalReleaseDate = group.originalReleaseDate,
        recordingDate = group.recordingDate,
        studio = group.studio,
        isLive = group.isLive,
        genres = List<String>.from(group.genres),
        coverImageUrl = group.coverImageUrl;

  final MusicReleaseGroup original;
  String title;
  String? sortTitle;
  String? artist;
  String? originalTitle;
  String? synopsis;
  DateTime? originalReleaseDate;
  DateTime? recordingDate;
  String? studio;
  bool? isLive;
  List<String> genres;
  String? coverImageUrl;

  MusicReleaseGroup toReleaseGroup() => MusicReleaseGroup(
        id: original.id,
        title: title.trim(),
        sortTitle: _text(sortTitle),
        artist: _text(artist),
        originalTitle: _text(originalTitle),
        synopsis: _text(synopsis),
        originalReleaseDate: originalReleaseDate,
        recordingDate: recordingDate,
        studio: _text(studio),
        isLive: isLive,
        genres: List.unmodifiable(genres),
        coverImageUrl: _text(coverImageUrl),
        coverImageKey: original.coverImageKey,
        releases: original.releases,
        metadataJson: original.metadataJson,
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
