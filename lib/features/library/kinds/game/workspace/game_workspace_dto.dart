import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class GameWorkspaceDto extends WorkspaceDtoAdapter {
  GameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.game,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final GameCatalogItem game;
}
