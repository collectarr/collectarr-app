import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';

/// Draft for creating a MusicBrainz-style release group with one release.
final class MusicReleaseGroupAddDraft {
  const MusicReleaseGroupAddDraft({
    required this.title,
    this.artist,
    this.publisher,
    this.catalogNumber,
    this.barcode,
    this.mediumType,
    this.countryCode,
    this.language,
    this.releaseDate,
    this.genres = const <String>[],
  });

  final String title;
  final String? artist;
  final String? publisher;
  final String? catalogNumber;
  final String? barcode;
  final String? mediumType;
  final String? countryCode;
  final String? language;
  final DateTime? releaseDate;
  final List<String> genres;

  MusicReleaseGroup toReleaseGroup({
    required MusicReleaseGroupId groupId,
    required MusicReleaseId releaseId,
  }) {
    final normalizedTitle = title.trim();
    final release = MusicRelease(
      id: releaseId,
      releaseGroupId: groupId,
      title: normalizedTitle,
      publisher: publisher,
      catalogNumber: catalogNumber,
      barcode: barcode,
      releaseDate: releaseDate,
      countryCode: countryCode,
      language: language,
      metadataJson: {
        'kind': 'music',
        if (mediumType != null) 'medium_type': mediumType,
      },
    );
    return MusicReleaseGroup(
      id: groupId,
      title: normalizedTitle,
      artist: artist,
      originalReleaseDate: releaseDate,
      genres: List.unmodifiable(genres),
      releases: [release],
    );
  }
}
