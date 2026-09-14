import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicWorkspaceDto implements LibraryWorkspaceDto {
  MusicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.music,
    required this.release,
    this.metadata,
  });

  final WorkspaceCommonProjection common;
  final PersonalCopyProjection personal;
  final MusicCatalogItem music;
  final MusicRelease release;
  final MusicCatalogMetadata? metadata;
  @override
  String get title => common.title;

  String? get synopsis => common.synopsis;
  String? get currency => common.currency;

  // Domain convenience getters
  String? get artist => release.artist ?? metadata?.artist ?? music.work.artist;
  String? get catalogNumber =>
      release.catalogNumber ?? metadata?.releases.firstOrNull?.catalogNumber;
  String? get seriesTitle => null;
  String? get itemNumber => null;
  String? get variant => null;
  String? get format =>
      release.media.firstOrNull?.mediaType ??
      release.releaseType ??
      metadata?.releases.firstOrNull?.format;
  String? get referenceFormatLabel => format;
  String? get publisher => release.publisher;
  DateTime? get releaseDate => release.releaseDate;
  String? get identifierCode => release.barcode;
  String? get barcode => identifierCode;
  String? get country => release.countryCode;
  String? get language => release.language;
  @override
  String? get coverImageUrl => release.coverImageUrl ?? common.coverImageUrl;
  int? get discCount => release.media.isNotEmpty
      ? release.media.length
      : metadata?.releases.firstOrNull?.mediaOrDiscCount;
  int? get trackCount => release.tracks.isNotEmpty
      ? release.tracks.length
      : metadata?.releases.firstOrNull?.tracks.length ??
          music.recording.trackCount;
  String? get releaseStatus => release.releaseStatus;
  bool? get isLive => release.isLive ?? metadata?.isLive;
  List<String> get genres => release.genres;
  List<Map<String, dynamic>> get credits => release.contributions;
  @override
  Iterable<String> get searchTokens => [
        if (artist != null) artist!,
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
        if (catalogNumber != null) catalogNumber!,
        ...genres,
      ];
}
