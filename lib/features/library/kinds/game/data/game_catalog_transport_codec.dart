import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_kind_transport_codec_defaults.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/data.dart';

final class GameCatalogTransportCodec
    with CatalogKindTransportCodecDefaults<GameCatalogMetadata> {
  const GameCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  GameCatalogMetadata decode(CatalogItemDto item) =>
      GameCatalogMetadata.fromJson(item.kindData);

  @override
  GameCatalogMetadata decodeKindData(Map<String, dynamic> kindData) =>
      GameCatalogMetadata.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, GameCatalogMetadata item) =>
      CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: item.toJson(),
      );

  @override
  CatalogDisplaySummary summarize(
    String catalogItemId,
    GameCatalogMetadata item,
  ) =>
      CatalogDisplaySummary.forCatalogItem(
        kind: kind,
        id: catalogItemId,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
      );

  @override
  GameWorkspaceData workspaceData(CatalogItemDto item) =>
      GameWorkspaceData(metadata: decode(item));

  @override
  GameWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      GameWorkspaceData(metadata: GameCatalogMetadata.fromJson(kindData));
}
