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
  String? get artist => music.artist;
  String? get catalogNumber => release.catalogNumber;
  String? get seriesTitle => null;
  String? get itemNumber => null;
  String? get variant => null;
  String? get format =>
      release.mediums.firstOrNull?.mediumType ?? release.releaseType;
  String? get referenceFormatLabel => format;
  String? get publisher => release.publisher;
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
}
