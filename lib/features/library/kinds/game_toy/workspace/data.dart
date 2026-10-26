import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class GameToyWorkspaceData implements LibraryWorkspaceKindData {
  GameToyWorkspaceData({
    required this.metadata,
  });

  factory GameToyWorkspaceData.fromTransport(CatalogItemDto item) {
    return GameToyWorkspaceData(
      metadata: GameToyCatalogMetadata.fromJson(item.kindData),
    );
  }

  final GameToyCatalogMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.gameToy;
  @override
  String get displayLabel => metadata.title;
}
