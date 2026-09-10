import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';

final class BoardGameWorkspaceDto extends WorkspaceDtoAdapter {
  BoardGameWorkspaceDto({
    required this.common,
    required this.personal,
    required this.boardgame,
    this.metadata,
  });

  @override
  final WorkspaceCommonProjection common;
  @override
  final PersonalCopyProjection personal;
  final BoardGameCatalogItem boardgame;
  final BoardGameMetadata? metadata;

  String? get publisher => boardgame.publisher ?? metadata?.publisher;
  @override
  String? get identifierCode => boardgame.barcode;
  String? get barcode => identifierCode;

  @override
  Iterable<String> get searchTokens => [
        if (publisher != null) publisher!,
        if (identifierCode != null) identifierCode!,
      ];
}
