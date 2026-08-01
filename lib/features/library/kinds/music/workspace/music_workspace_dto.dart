import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MusicWorkspaceDto extends WorkspaceDtoAdapter {
  MusicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.music,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final MusicCatalogItem music;
}
