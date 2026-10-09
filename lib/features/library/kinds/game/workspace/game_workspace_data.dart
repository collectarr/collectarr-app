import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class GameWorkspaceData implements LibraryWorkspaceKindData {
  GameWorkspaceData({
    required this.metadata,
  });

  factory GameWorkspaceData.fromTransport(CatalogItemDto item) {
    return GameWorkspaceData(
      metadata: GameCatalogMetadata.fromJson(item.kindData),
    );
  }

  final GameCatalogMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;
  @override
  String get displayLabel => metadata.title;
}
