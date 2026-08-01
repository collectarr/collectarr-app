import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class ComicWorkspaceDto extends WorkspaceDtoAdapter {
  ComicWorkspaceDto({
    required this.common,
    required this.personal,
    required this.comic,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final ComicCatalogItem comic;
}
