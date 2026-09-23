import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';

/// Draft for creating a MusicBrainz-style release group with one release.
final class MusicReleaseGroupAddDraft {
  const MusicReleaseGroupAddDraft({
    required this.title,
    this.releaseTitle,
    this.artist,
    this.publisher,
    this.catalogNumber,
    this.barcode,
    this.mediumType,
    this.packaging,
    this.countryCode,
    this.language,
    this.releaseDate,
    this.genres = const <String>[],
    this.coverImageUrl,
  });

  final String title;
  final String? releaseTitle;
  final String? artist;
  final String? publisher;
  final String? catalogNumber;
  final String? barcode;
  final String? mediumType;
  final String? packaging;
  final String? countryCode;
  final String? language;
  final DateTime? releaseDate;
  final List<String> genres;
  final String? coverImageUrl;

  MusicReleaseGroup toReleaseGroup({
    required MusicReleaseGroupId groupId,
    required MusicReleaseId releaseId,
  }) {
    final normalizedTitle = title.trim();
    final release = MusicRelease(
      id: releaseId,
      releaseGroupId: groupId,
      title: releaseTitle?.trim().isNotEmpty == true
          ? releaseTitle!.trim()
          : normalizedTitle,
      publisher: publisher,
      catalogNumber: catalogNumber,
      barcode: barcode,
      releaseDate: releaseDate,
      countryCode: countryCode,
      language: language,
      packaging: packaging,
      mediums: mediumType?.trim().isNotEmpty == true
          ? [
              MusicMedium(
                id: MusicMediumId('${releaseId.value}:medium:1'),
                releaseId: releaseId,
                mediumNumber: 1,
                mediumType: mediumType!.trim(),
              ),
            ]
          : const [],
    );
    return MusicReleaseGroup(
      id: groupId,
      title: normalizedTitle,
      artist: artist,
      originalReleaseDate: releaseDate,
      genres: List.unmodifiable(genres),
      releases: [release],
      coverImageUrl: coverImageUrl,
    );
  }
}
