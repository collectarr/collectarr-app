import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';

final class BoardGameWorkspaceData implements LibraryWorkspaceKindData {
  BoardGameWorkspaceData({
    required this.metadata,
  });

  factory BoardGameWorkspaceData.fromTransport(CatalogItemDto item) {
    return BoardGameWorkspaceData(
      metadata: BoardGameMetadata.fromJson(item.kindData),
    );
  }

  final BoardGameMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;
  @override
  String get displayLabel => metadata.title;
}
