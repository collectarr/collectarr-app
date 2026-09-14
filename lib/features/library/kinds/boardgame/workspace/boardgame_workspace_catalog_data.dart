import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/catalog/boardgame_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class BoardGameWorkspaceCatalogData
    implements LibraryWorkspaceCatalogData {
  BoardGameWorkspaceCatalogData({
    required this.ref,
    required this.boardgame,
    required this.metadata,
  });

  factory BoardGameWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return BoardGameWorkspaceCatalogData(
      ref: item.catalogRef,
      boardgame: BoardGameCatalogMapper.mapMetadataItemToBoardGame(item),
      metadata: rawMetadata is BoardGameMetadata
          ? rawMetadata
          : rawMetadata == null
              ? null
              : BoardGameMetadata.fromJson(item.payload),
    );
  }

  @override
  final CatalogEntityRef ref;
  final BoardGameCatalogItem boardgame;
  final BoardGameMetadata? metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.boardgame;
  @override
  String get title => boardgame.title;
  @override
  String? get synopsis => boardgame.synopsis;
  @override
  DateTime? get releaseDate => boardgame.releaseDate;
  @override
  String? get coverImageUrl => boardgame.coverImageUrl;
  @override
  String? get thumbnailImageUrl => boardgame.coverImageUrl;
}
