import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicWorkspaceDto extends WorkspaceDtoAdapter {
  MusicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.music,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final MusicCatalogItem music;
  final MusicCatalogMetadata? metadata;

  // Domain convenience getters
  String? get artist => metadata?.artist ?? music.work.artist;
  String? get catalogNumber => metadata?.releases.firstOrNull?.catalogNumber;
  @override
  String? get format => metadata?.releases.firstOrNull?.format;
  @override
  String? get country => metadata?.releases.firstOrNull?.country;
  int? get discCount => metadata?.releases.firstOrNull?.mediaOrDiscCount;
  int? get trackCount =>
      metadata?.releases.firstOrNull?.tracks.length ??
      music.recording.trackCount;
}
