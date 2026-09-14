import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

/// Draft for creating a Music release independently from its parent catalog
/// item or from a generic edition draft.
final class MusicReleaseAddDraft {
  const MusicReleaseAddDraft({
    required this.title,
    this.artist,
    this.publisher,
    this.catalogNumber,
    this.barcode,
    this.format,
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
  final String? format;
  final String? countryCode;
  final String? language;
  final DateTime? releaseDate;
  final List<String> genres;

  MusicRelease toRelease(MusicReleaseId id) {
    return MusicRelease(
      id: id,
      title: title.trim(),
      artist: artist,
      publisher: publisher,
      catalogNumber: catalogNumber,
      barcode: barcode,
      releaseDate: releaseDate,
      countryCode: countryCode,
      language: language,
      genres: genres,
      media: const [],
      tracks: const [],
      rawPayload: {
        'kind': 'music',
        if (format != null) 'format': format,
      },
    );
  }
}
