import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

final class MusicReleaseEditDraft {
  MusicReleaseEditDraft.fromRelease(MusicRelease release)
      : original = release,
        title = release.title,
        artist = release.artist,
        publisher = release.publisher,
        catalogNumber = release.catalogNumber,
        barcode = release.barcode,
        releaseDate = release.releaseDate,
        recordingDate = release.recordingDate,
        releaseStatus = release.releaseStatus,
        releaseType = release.releaseType,
        sortTitle = release.sortTitle,
        subtitle = release.subtitle,
        studio = release.studio,
        countryCode = release.countryCode,
        language = release.language,
        coverImageUrl = release.coverImageUrl,
        genres = List<String>.from(release.genres),
        contributions = [
          for (final contribution in release.contributions)
            Map<String, dynamic>.from(contribution),
        ];

  final MusicRelease original;
  String title;
  String? artist;
  String? publisher;
  String? catalogNumber;
  String? barcode;
  DateTime? releaseDate;
  DateTime? recordingDate;
  String? releaseStatus;
  String? releaseType;
  String? sortTitle;
  String? subtitle;
  String? studio;
  String? countryCode;
  String? language;
  String? coverImageUrl;
  List<String> genres;
  List<Map<String, dynamic>> contributions;

  MusicRelease toRelease() => MusicRelease(
        id: original.id,
        title: title.trim(),
        artist: _text(artist),
        publisher: _text(publisher),
        catalogNumber: _text(catalogNumber),
        barcode: _text(barcode),
        releaseDate: releaseDate,
        recordingDate: recordingDate,
        releaseStatus: _text(releaseStatus),
        releaseType: _text(releaseType),
        sortTitle: _text(sortTitle),
        subtitle: _text(subtitle),
        studio: _text(studio),
        countryCode: _text(countryCode),
        language: _text(language),
        coverImageUrl: _text(coverImageUrl),
        genres: List.unmodifiable(genres),
        contributions: [
          for (final contribution in contributions)
            Map<String, dynamic>.from(contribution),
        ],
        media: original.media,
        tracks: original.tracks,
        isLive: original.isLive,
        rawPayload: {
          ...original.rawPayload,
          'genres': genres,
          'contributions': contributions,
        },
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
