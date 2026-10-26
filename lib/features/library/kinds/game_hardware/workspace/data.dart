import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class GameHardwareWorkspaceData implements LibraryWorkspaceKindData {
  GameHardwareWorkspaceData({
    required this.metadata,
  });

  factory GameHardwareWorkspaceData.fromTransport(CatalogItemDto item) {
    return GameHardwareWorkspaceData(
      metadata: GameHardwareCatalogMetadata.fromJson(item.kindData),
    );
  }

  final GameHardwareCatalogMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.gameHardware;
  @override
  String get displayLabel => metadata.title;
}
