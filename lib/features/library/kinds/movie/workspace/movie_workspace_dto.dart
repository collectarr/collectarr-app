import 'package:collectarr_app/features/library/kinds/_shared/video/catalog/video_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class MovieWorkspaceDto extends WorkspaceDtoAdapter {
  MovieWorkspaceDto({
    required this.common,
    required this.personal,
    required this.movie,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final VideoCatalogItem movie;

  VideoCatalogItem get video => movie;
}
