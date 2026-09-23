import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';

/// Draft for the conceptual MusicBrainz release group (the library item).
final class MusicReleaseGroupEditDraft {
  MusicReleaseGroupEditDraft.fromReleaseGroup(MusicReleaseGroup group)
      : original = group,
        title = group.title,
        sortTitle = group.sortTitle,
        artist = group.artist,
        originalTitle = group.originalTitle,
        originalReleaseDate = group.originalReleaseDate,
        recordingDate = group.recordingDate,
        studio = group.studio,
        isLive = group.isLive,
        genres = List<String>.from(group.genres),
        coverImageUrl = group.coverImageUrl,
        externalLinks = List<MusicExternalLink>.from(group.externalLinks),
        localCoverImagePath = group.localCoverImagePath,
        localBackImagePath = group.localBackImagePath,
        localThumbnailImagePath = group.localThumbnailImagePath;

  final MusicReleaseGroup original;
  String title;
  String? sortTitle;
  String? artist;
  String? originalTitle;
  DateTime? originalReleaseDate;
  DateTime? recordingDate;
  String? studio;
  bool? isLive;
  List<String> genres;
  String? coverImageUrl;
  List<MusicExternalLink> externalLinks;
  String? localCoverImagePath;
  String? localBackImagePath;
  String? localThumbnailImagePath;

  MusicReleaseGroup toReleaseGroup() => MusicReleaseGroup(
        id: original.id,
        title: title.trim(),
        sortTitle: _text(sortTitle),
        artist: _text(artist),
        originalTitle: _text(originalTitle),
        originalReleaseDate: originalReleaseDate,
        originalReleaseDateParts:
            originalReleaseDate == original.originalReleaseDate
                ? original.originalReleaseDateParts
                : null,
        recordingDate: recordingDate,
        recordingDateParts: recordingDate == original.recordingDate
            ? original.recordingDateParts
            : null,
        studio: _text(studio),
        isLive: isLive,
        genres: List.unmodifiable(genres),
        artistCredits: original.artistCredits,
        coverImageUrl: _text(coverImageUrl),
        coverImageKey: original.coverImageKey,
        externalLinks: List.unmodifiable(externalLinks),
        releases: original.releases,
        localCoverImagePath: _text(localCoverImagePath),
        localBackImagePath: _text(localBackImagePath),
        localThumbnailImagePath: _text(localThumbnailImagePath),
        createdAt: original.createdAt,
        updatedAt: original.updatedAt,
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
