import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceDto extends WorkspaceDtoAdapter {
  BoardGameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.boardgame,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final BoardGameCatalogItem boardgame;
}
