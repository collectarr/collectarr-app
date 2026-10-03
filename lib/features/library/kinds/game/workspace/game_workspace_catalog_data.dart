import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';

final class GameWorkspaceCatalogData
    implements
        LibraryWorkspaceCatalogData,
        LibraryWorkspaceCatalogSynopsisData {
  GameWorkspaceCatalogData({
    required this.ref,
    required this.metadata,
  });

  factory GameWorkspaceCatalogData.fromTransport(CatalogItemDto item) {
    return GameWorkspaceCatalogData(
      ref: item.catalogRef,
      metadata: GameCatalogMetadata.fromJson(item.kindData),
    );
  }

  @override
  final CatalogEntityRef ref;
  final GameCatalogMetadata metadata;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;
  @override
  String get title => metadata.title;
  @override
  String? get synopsis => metadata.synopsis;
  @override
  DateTime? get releaseDate => metadata.releaseDate;
  @override
  String? get coverImageUrl => metadata.coverImageUrl;
  @override
  String? get thumbnailImageUrl =>
      metadata.thumbnailImageUrl ?? metadata.coverImageUrl;
}
