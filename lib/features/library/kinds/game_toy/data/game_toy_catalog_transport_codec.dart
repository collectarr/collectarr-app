import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_kind_transport_codec_defaults.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/domain/game_toy_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/workspace/data.dart';

final class GameToyCatalogTransportCodec
    with CatalogKindTransportCodecDefaults<GameToyCatalogMetadata> {
  const GameToyCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.gameToy;

  @override
  GameToyCatalogMetadata decode(CatalogItemDto item) =>
      GameToyCatalogMetadata.fromJson(item.kindData);

  @override
  GameToyCatalogMetadata decodeKindData(Map<String, dynamic> kindData) =>
      GameToyCatalogMetadata.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, GameToyCatalogMetadata item) =>
      CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: item.toJson(),
      );

  @override
  CatalogDisplaySummary summarize(
    String catalogItemId,
    GameToyCatalogMetadata item,
  ) =>
      CatalogDisplaySummary.forCatalogItem(
        kind: kind,
        id: catalogItemId,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
      );

  @override
  GameToyWorkspaceData workspaceData(CatalogItemDto item) =>
      GameToyWorkspaceData(metadata: decode(item));

  @override
  GameToyWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      GameToyWorkspaceData(metadata: GameToyCatalogMetadata.fromJson(kindData));
}
