import 'package:collectarr_app/features/library/kinds/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class TvWorkspaceDto extends WorkspaceDtoAdapter {
  TvWorkspaceDto({
    required this.common,
    required this.personal,
    required this.tv,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final VideoCatalogItem tv;
}
