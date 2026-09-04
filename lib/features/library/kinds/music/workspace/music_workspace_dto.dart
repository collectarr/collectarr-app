import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicWorkspaceDto extends WorkspaceDtoAdapter {
  MusicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.music,
    required this.release,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final MusicCatalogItem music;
  final MusicRelease release;
  final MusicCatalogMetadata? metadata;

  // Domain convenience getters
  String? get artist => release.artist ?? metadata?.artist ?? music.work.artist;
  String? get catalogNumber =>
      release.catalogNumber ?? metadata?.releases.firstOrNull?.catalogNumber;
  @override
  String? get format =>
      release.media.firstOrNull?.mediaType ??
      release.releaseType ??
      metadata?.releases.firstOrNull?.format;
  @override
  String? get publisher => release.publisher ?? common.publisher;
  @override
  DateTime? get releaseDate => release.releaseDate ?? common.releaseDate;
  @override
  String? get barcode => release.barcode ?? common.barcode;
  @override
  String? get country => release.countryCode ?? common.country;
  @override
  String? get language => release.language ?? common.language;
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
}
