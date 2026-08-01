import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class AnimeWorkspaceDto extends WorkspaceDtoAdapter {
  AnimeWorkspaceDto({
    required this.common,
    required this.personal,
    required this.anime,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final VideoCatalogItem anime;
}
