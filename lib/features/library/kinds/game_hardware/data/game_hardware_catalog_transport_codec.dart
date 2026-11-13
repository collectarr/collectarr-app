import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_kind_transport_codec_defaults.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/data.dart';

final class GameHardwareCatalogTransportCodec
    with CatalogKindTransportCodecDefaults<GameHardwareCatalogMetadata> {
  const GameHardwareCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.gameHardware;

  @override
  GameHardwareCatalogMetadata decode(CatalogItemDto item) =>
      GameHardwareCatalogMetadata.fromJson(item.kindData);

  @override
  GameHardwareCatalogMetadata decodeKindData(Map<String, dynamic> kindData) =>
      GameHardwareCatalogMetadata.fromJson(kindData);

  @override
  CatalogItemDto encode(String id, GameHardwareCatalogMetadata item) =>
      CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: item.toJson(),
      );

  @override
  CatalogDisplaySummary summarize(
    String catalogItemId,
    GameHardwareCatalogMetadata item,
  ) =>
      CatalogDisplaySummary.forCatalogItem(
        kind: kind,
        id: catalogItemId,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
      );

  @override
  GameHardwareWorkspaceData workspaceData(CatalogItemDto item) =>
      GameHardwareWorkspaceData(metadata: decode(item));

  @override
  GameHardwareWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      GameHardwareWorkspaceData(
          metadata: GameHardwareCatalogMetadata.fromJson(kindData));
}
