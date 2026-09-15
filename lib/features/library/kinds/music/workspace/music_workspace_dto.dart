import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicWorkspaceDto implements LibraryWorkspaceDto {
  MusicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.music,
    required this.release,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final MusicReleaseGroup music;
  final MusicRelease release;
  @override
  String get title => common.title;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  // Domain convenience getters
  String? get artist => music.artist ?? _releaseArtist;
  String? get catalogNumber => release.catalogNumber;

  /// The shared presentation contract calls the primary grouping value
  /// `seriesTitle`; Music owns that slot as the artist credit.
  String? get seriesTitle => artist;
  String? get itemNumber => null;
  String? get variant => null;
  String? get format =>
      release.mediums.firstOrNull?.mediumType ?? release.releaseType;
  String? get referenceFormatLabel => format;
  String? get releaseType => release.releaseType;
  String? get packaging => release.packaging;
  String? get boxSet => release.boxSetTitle;
  String? get publisher => release.publisher;
  String? get genre => music.genres.isEmpty ? null : music.genres.join(', ');
  int? get releaseCount => music.releases.length;
  DateTime? get releaseDate => release.releaseDate;
  String? get identifierCode => release.barcode ?? release.upc;
  String? get barcode => identifierCode;
  String? get country => release.countryCode;
  String? get language => release.language;
  @override
  String? get coverImageUrl => release.coverImageUrl ?? common.coverImageUrl;
  int? get discCount => release.mediums.isEmpty ? null : release.mediums.length;
  int? get trackCount =>
      release.tracks.isNotEmpty ? release.tracks.length : music.trackCount;
  String? get releaseStatus => release.releaseStatus;
  bool? get isLive => music.isLive;
  List<String> get genres => music.genres;
  List<Map<String, dynamic>> get credits => [
        for (final contribution in release.contributions) contribution.toJson(),
      ];
  @override
  Iterable<String> get searchTokens => [
        if (artist != null) artist!,
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (catalogNumber != null) catalogNumber!,
        ...genres,
      ];

  String? get _releaseArtist {
    for (final contribution in release.contributions) {
      final role = contribution.role.trim().toLowerCase();
      if (!(role.contains('artist') ||
          role.contains('performer') ||
          role.contains('musician') ||
          role.contains('band'))) {
        continue;
      }
      final name = contribution.displayName?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return null;
  }
}
