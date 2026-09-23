import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/game/catalog/game_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class GameWorkspaceCatalogData
    implements
        LibraryWorkspaceCatalogData,
        LibraryWorkspaceCatalogSynopsisData {
  GameWorkspaceCatalogData({
    required this.ref,
    required this.game,
    required this.metadata,
  });

  factory GameWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    final rawMetadata = item.kindMetadata;
    return GameWorkspaceCatalogData(
      ref: item.catalogRef,
      game: GameCatalogMapper.mapMetadataItemToGame(item),
      metadata: rawMetadata is GameCatalogMetadata
          ? rawMetadata
          : rawMetadata == null
              ? null
              : GameCatalogMetadata.fromJson(item.payload),
    );
  }

  @override
  final CatalogEntityRef ref;
  final GameCatalogItem game;
  final GameCatalogMetadata? metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;
  @override
  String get title => game.title;
  @override
  String? get synopsis => game.synopsis;
  @override
  DateTime? get releaseDate => game.releaseDate;
  @override
  String? get coverImageUrl => game.coverImageUrl;
  @override
  String? get thumbnailImageUrl => game.coverImageUrl;
}
